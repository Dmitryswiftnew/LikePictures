import UIKit
import SnapKit
import KeychainSwift
import AudioToolbox

final class EnterPasswordViewController: UIViewController {
    
    private var enterPassword = ""
    
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
        label.text = "Чтоб войти введите свой PIN"
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
        enterStep()
//                                          //////
        let manager = SaveLoadManager()
            manager.resetPassword()
            
            
            let createVC = CreatePasswordViewController()
            let navController = UINavigationController(rootViewController: createVC)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
            }
        
        //                            /////
    }

    
    // - MARK: CofigureUI
    
    func configureUI() {
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
    private func enterStep() {
        enterPassword = ""
        hiddenTextField.text = ""
        clearDots()
        dotsContainer.alpha = 1
        updateDots()
    }
        
    
    // - MARK: Update dots
    
    private func updateDots() {
        
        for (index, dotView) in dotViews.enumerated() {
            let isFilled = index < enterPassword.count
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
                    self.enterStep()
                }
            }
        }
    }
    
        
    private func checkPasswords() {
        let manager = SaveLoadManager()
        
        guard let savedPassword = manager.loadPassword()
        else {
            return
        }
        if enterPassword == savedPassword {
            performNavigationToMain()
        } else {
            AudioServicesPlaySystemSound(1053)
            showErrorAlert(title: "Неверный PIN", message: "Попробуйте еще раз")
            shakeAnimation()
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
    
}


extension EnterPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.length <= 1 else { return true }
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let limitedText = String(newText.prefix(4))
        
        enterPassword = limitedText
        
        AudioServicesPlaySystemSound(1104)
        
        if enterPassword.count == 4 {
                self.checkPasswords()
        }
        
        updateDots()
        return true
    }
}
