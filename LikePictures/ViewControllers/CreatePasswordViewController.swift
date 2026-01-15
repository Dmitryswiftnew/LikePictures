import UIKit
import SnapKit
import KeychainSwift

final class CreatePasswordViewController: UIViewController {
    
    private var centerYConstraint: Constraint?
    
    private let mainImage: UIImageView = {
        let obj = UIImageView()
        obj.image = UIImage(named: "CrPassword")
        obj.contentMode = .scaleAspectFill
        obj.clipsToBounds = true
        return obj
    }()
    
    private let passwordTextField: UITextField = {
        let obj = UITextField()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20,weight: .regular)
        ]
        obj.attributedPlaceholder = NSAttributedString(string: "Ввведите 4-значный PIN", attributes: attributes)
        
//        textField.placeholder = "Введите пароль"
        obj.backgroundColor = .white.withAlphaComponent(0.5)
        obj.layer.borderColor = UIColor.white.cgColor
        obj.layer.borderWidth = 2
        obj.layer.cornerRadius = 12
        obj.textColor = .black
        obj.isSecureTextEntry = true
        return obj
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let obj = UITextField()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20,weight: .regular)
        ]
        obj.attributedPlaceholder = NSAttributedString(string: "Подтвердите PIN", attributes: attributes)
//        textField.placeholder = "Подтвердите PIN"
        obj.backgroundColor = .white.withAlphaComponent(0.5)
        obj.layer.borderColor = UIColor.white.cgColor
        obj.layer.borderWidth = 2
        obj.layer.cornerRadius = 12
        obj.textColor = .black
        obj.isSecureTextEntry = true
        return obj
    }()
    
    
    private let createPasswordButton: UIButton = {
        let obj = UIButton(type: .system)
        obj.setTitle("Создать пароль", for: .normal)
        obj.setTitleColor(.white, for: .normal)
        obj.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        obj.layer.borderWidth = 2
        obj.layer.borderColor = UIColor.white.cgColor
        obj.layer.cornerRadius = 12
        obj.contentEdgeInsets = UIEdgeInsets(top: 14, left: 40, bottom: 14, right: 40)
        return obj
    }()
    
    private let mainContainerView: UIView = {
        let obj = UIView()
//        view.backgroundColor = .red
//        view.alpha = 0.2
        obj.isUserInteractionEnabled = true
        return obj
    }()
    
    private let containerTextField: UIView = {
        let obj = UIView()
//        view.backgroundColor = .green
//        view.alpha = 0.3
        return obj
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotifiacations()
//        let manager = SaveLoadManager()
//            print("Картинка:", UIImage(named: "CreatePassword") != nil)
//
//            
//
//            manager.savePassword("1234")
//            print("Сохранён пароль:", manager.loadPassword() ?? "nil")
//            print("Флаг создан:", manager.isPasswordCreated())
//            manager.resetPassword()
        
    }
    
    // - MARK: Configure UI
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainImage)
        mainImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainContainerView.addSubview(containerTextField)
        containerTextField.snp.makeConstraints { make in
//            make.width.equalToSuperview().inset(40)
            make.height.equalToSuperview().multipliedBy(1.0 / 3.0)
            make.centerX.equalToSuperview()
            self.centerYConstraint = make.centerY.equalTo(mainContainerView).constraint
        }
        
        containerTextField.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(containerTextField.snp.top)
            make.left.right.equalTo(containerTextField).inset(20)
            make.height.equalTo(50)
        }
        
        containerTextField.addSubview(confirmPasswordTextField)
        confirmPasswordTextField.snp.makeConstraints { make in
            make.center.equalTo(containerTextField)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(passwordTextField)
        }
        
        containerTextField.addSubview(createPasswordButton)
        createPasswordButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerTextField.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        
        let action = UIAction { _ in
            self.createPasswordPressed()
        }
        
        createPasswordButton.addAction(action, for: .touchUpInside)
        
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tapRecognizer)
        
        
    }
    
    // - MARK: Create Password Button
    
    private func createPasswordPressed() {
        guard let password = passwordTextField.text,
              let confirm = confirmPasswordTextField.text,
              !password.isEmpty, !confirm.isEmpty else {
            showErrorAlert(title: "Пустые поля", message: "Заполните все поля")
            return
        }
        
        if password.count != 4 {
            showErrorAlert(title: "Неверная длина", message: "PIN должен содержать 4 цифры")
            return
        }
        
        if password != confirm {
            showErrorAlert(title: "Пароли не совпадают")
            return
        }
        
        let manager = SaveLoadManager()
        manager.savePassword(password)
        performNavigationToMain()
        
    }
    
    
    
    
    
    
    // - MARK: Keybord switch
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        centerYConstraint?.update(offset: -keyboardFrame.height / 2)
        
        UIView.animate(withDuration: duration) {
              self.view.layoutIfNeeded()
          }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        centerYConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    private func configureNotifiacations() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
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

