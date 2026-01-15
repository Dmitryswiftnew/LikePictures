import UIKit
import SnapKit
import KeychainSwift

final class EnterPasswordViewController: UIViewController {
    
    private let mainImage: UIImageView = {
        let obj = UIImageView()
        obj.image = UIImage(named: "IntPassword")
        obj.contentMode = .scaleAspectFill
        obj.clipsToBounds = true
        return obj
    }()
    
    private let enterPasswordTextField: UITextField = {
        let obj = UITextField()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20,weight: .regular)
        ]
        obj.attributedPlaceholder = NSAttributedString(string: "Ввведите PIN", attributes: attributes)
        obj.backgroundColor = .white.withAlphaComponent(0.5)
        obj.layer.borderColor = UIColor.white.cgColor
        obj.layer.borderWidth = 2
        obj.layer.cornerRadius = 12
        obj.textColor = .black
        obj.isSecureTextEntry = true
        return obj
    }()
    
    private let mainContainer: UIView = {
        let obj = UIView()
        obj.isUserInteractionEnabled = true
        return obj
    }()
    
    private let containerTextField: UIView = {
        let obj = UIView()
        return obj
    }()
    
    private let enterPasswordButton: UIButton = {
        let obj = UIButton(type: .system)
        obj.setTitle("Войти", for: .normal)
        obj.setTitleColor(.white, for: .normal)
        obj.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        obj.layer.borderWidth = 2
        obj.layer.borderColor = UIColor.white.cgColor
        obj.layer.cornerRadius = 12
        obj.contentEdgeInsets = UIEdgeInsets(top: 14, left: 40, bottom: 14, right: 40)
        return obj
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    
    // - MARK: CofigureUI
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainImage)
        mainImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainContainer.addSubview(containerTextField)
        containerTextField.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(1.0 / 6.0)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        
        containerTextField.addSubview(enterPasswordTextField)
        enterPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(containerTextField.snp.top)
            make.left.right.equalTo(containerTextField).inset(20)
            make.height.equalTo(50)
        }
        
        containerTextField.addSubview(enterPasswordButton)
        enterPasswordButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerTextField.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
    
        
        let action = UIAction { _ in
            self.enterPasswordButtonPressed()
        }
        
        enterPasswordButton.addAction(action, for: .touchUpInside)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tapRecognizer)
        
 
    }
    
    
    private func enterPasswordButtonPressed() {
        guard let inputPassword = enterPasswordTextField.text,
              inputPassword.count == 4,
              !inputPassword.isEmpty else {
            showErrorAlert(title: "Неверная длина", message: "PIN должен быть 4x значный")
            return
        }
        
        let manager = SaveLoadManager()
        if inputPassword == manager.loadPassword() && inputPassword.count == 4 {
            performNavigationToMain()
        } else {
            showErrorAlert(title: "Неверны PIN-код")
            enterPasswordTextField.text = ""
        }
    }
    

    // - MARK: Tap gesture
    
    @objc func tapDetected() {
        view.endEditing(true)
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
