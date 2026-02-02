

import Foundation
import SnapKit
import UIKit


final class AddImageViewController: UIViewController  {
    
    private var centerYConstraint: Constraint?
    private var saveManager = SaveLoadManager()
    
    private let mainContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var imageContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    

    private var buttonBack: UIButton = {
        let button = UIButton(type: .system)
        let backImage = UIImage(systemName: "chevron.left")
        button.setImage(backImage, for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var buttonCancel: UIButton = {
        let button = UIButton(type: .system)
        let backImage = UIImage(systemName: "xmark")
        button.setImage(backImage, for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        let emptyImage = UIImage(systemName: "heart")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
        button.setImage(emptyImage, for: .normal)
        
        
        let filledImage = UIImage(systemName: "heart.fill")?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
        button.setImage(filledImage, for: .selected)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var photoImage: UIImageView = {
        let view = UIImageView()
        let backImage = UIImage(systemName: "person.crop.circle.fill.badge.plus")
        view.image = backImage
        view.tintColor = .white
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.alpha = 1
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    

    private var textFiled: UITextField = {
        let textField = UITextField()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20,weight: .regular)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Add description", attributes: attributes)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white.withAlphaComponent(0.5)
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 12
        return textField
    }()
    
    
    
    private let buttonHeaderContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotifiacations()
    }
    
    private func configureUI() {
        view.backgroundColor = .green
        
        
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainContainerView.addSubview(imageContainer)
        imageContainer.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.height.equalToSuperview().dividedBy(2)
            self.centerYConstraint = make.centerY.equalTo(mainContainerView).constraint
        }
        
        
        mainContainerView.addSubview(buttonHeaderContainer)
        buttonHeaderContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalToSuperview().dividedBy(20)
        }
        
        buttonHeaderContainer.addSubview(buttonBack)
        buttonBack.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let actionButtonBack = UIAction { _ in
            self.backButtonPressed()
        }
        buttonBack.addAction(actionButtonBack, for: .touchUpInside)
      
        buttonHeaderContainer.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        let actionLikeButton = UIAction { _ in
            self.likeButttonTaped()
        }
        likeButton.addAction(actionLikeButton, for: .touchUpInside)
        
        buttonHeaderContainer.addSubview(buttonCancel)
        buttonCancel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
       
       
        let actionCancel = UIAction { [weak self] _ in
            self?.showExitConfirmAlert {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        buttonCancel.addAction(actionCancel, for: .touchUpInside)
        
        
        
        imageContainer.addSubview(photoImage)
        photoImage.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(photoImage.snp.width).multipliedBy(0.95)
        }
        
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(photoImageTapped))
        photoImage.addGestureRecognizer(tapImageGesture)
        
        imageContainer.addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageContainer.snp.bottom)
            make.height.equalToSuperview().multipliedBy(1.0 / 9.0)
        }
        

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tapRecognizer)
        
    }
    
    
    // - MARK: ImagePicker
    
    private func showPicker(_ sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    
    
    private func showImagePickerAlert() {
        let alert = UIAlertController(
            title: "Chose media source",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.showPicker(.camera)
        }
        alert.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.showPicker(.photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc func photoImageTapped() {         //
        showImagePickerAlert()
    }
    
    @objc func tapDetected() {
        textFiled.endEditing(true)
    }
    

    // - MARK: like button tapped
    
    private func likeButttonTaped() {
        likeButton.isSelected.toggle()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.likeButton.transform = .identity
            }
        }
    }
    
    
    // - MARK: Autosave image
    
    private func saveCurrentImage() {
        guard let currentImage = photoImage.image,
              currentImage != UIImage(systemName: "person.crop.circle.fill.badge.plus") else { return }
        
        
        guard let fileName = saveManager.saveImage(image: currentImage) else {
            return
        }
        
        
        let newItem = ImageItem(
            id: UUID().uuidString,
            fileName: fileName,
            description: textFiled.text?.isEmpty != true ? textFiled.text : nil,
            isLiked: likeButton.isSelected)
        

        
        if let mainViewController = navigationController?.viewControllers.first(where: { $0 is MainViewController }) as? MainViewController {
            mainViewController.addImageItem(newItem)
        }
    }
    
    // - MARK: Back button navigation
    
   private func backButtonPressed() {
       saveCurrentImage()
       navigationController?.popViewController(animated: true)
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
  
}


extension AddImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        self.photoImage.image = image
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
