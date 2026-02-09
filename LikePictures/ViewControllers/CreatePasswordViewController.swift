import UIKit
import SnapKit
import KeychainSwift
import AudioToolbox

final class CreatePasswordViewController: UIViewController {
    
    private var firstPassword = ""
    private var secondPassword = ""
    private var isFirstStep = true
    
    private let dotViews: [UIImageView] = (0..<4).map { _ in
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private let hiddenTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.isHidden = true
        return textField
    }()
    
    private let dotsContainer = UIView()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        startFirstStep()
    }
    
    // - MARK: Configure UI
    
    private func configureUI() {
        view.backgroundColor = .black
        
        dotViews.forEach { dotsStackView.addArrangedSubview($0) }
        
        dotsContainer.addSubview(dotsStackView)
        dotsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(dotsContainer)
        dotsContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(dotsContainer.snp.top).offset(-30)
        }
        view.addSubview(hiddenTextField)
        hiddenTextField.delegate = self
        hiddenTextField.becomeFirstResponder()
    }
    
    
    private func startFirstStep() {
        isFirstStep = true
        firstPassword = ""
        hiddenTextField.text = ""
        instructionLabel.text = "Создайте 4-значный PIN"
        clearDots()
        dotsContainer.alpha = 1
        updateDots()
    }
    
    private func startSecondStep() {
        isFirstStep = false
        instructionLabel.text = "Подтвердите PIN"
        clearDots()
        secondPassword = ""
        hiddenTextField.text = ""
    }
    
    // - MARK: Update dots
    
    private func updateDots() {
        let currentPassword = isFirstStep ? firstPassword : secondPassword
        
        for (index, dotView) in dotViews.enumerated() {
            let isFilled = index < currentPassword.count
            dotView.image = UIImage(systemName: isFilled ? "circle.fill" : "circle")
        }
    }
    
    // - MARK: Clear dots
    
    private func clearDots() {
        for dotView in dotViews {
            dotView.image = UIImage(systemName: "circle")
        }
    }
    
    
    // - MARK: Animation wrong PIN
    
    private func shakeAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.dotsContainer.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.dotsContainer.transform = CGAffineTransform(translationX: -10, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.dotsContainer.transform = .identity
                } completion: { _ in
                    self.startFirstStep()
                }
            }
        }
    }
    
    // - MARK: Check passwords
    
    private func checkPasswords() {
        if firstPassword == secondPassword {
            AudioServicesPlaySystemSound(1057)
            SaveLoadManager().savePassword(firstPassword)
            performNavigationToMain()
        } else {
            shakeAnimation()
            AudioServicesPlaySystemSound(1053)
        }
    }
}


// - MARK: Navigation
private func performNavigationToMain() {
    let controller = MainViewController()
    
    let navController = UINavigationController(rootViewController: controller)
    navController.setNavigationBarHidden(true, animated: false)
    
    GlobalCoordinator.window?.rootViewController = navController
    GlobalCoordinator.window?.makeKeyAndVisible()
}

extension CreatePasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.length <= 1 else { return true }
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let limitedText = String(newText.prefix(4))
        
        AudioServicesPlaySystemSound(1104)
       
        if isFirstStep {
            firstPassword = limitedText
            if firstPassword.count == 4 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.dotsContainer.alpha = 0.5
                }) { _ in
                    self.startSecondStep()
                }
            }
        } else {
            secondPassword = limitedText
            if secondPassword.count == 4 {
                UIView.animate(withDuration: 0.3) {
                    self.dotsContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                } completion: { _ in
                    self.checkPasswords()
                }
            }
        }
        
        updateDots()
        return true
    }
}
