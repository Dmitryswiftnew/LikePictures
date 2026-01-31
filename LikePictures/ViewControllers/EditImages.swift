
import Foundation
import UIKit
import SnapKit


final class EditImages: UIViewController {
    
    private var centerYConstraint: Constraint?
    private var imageIndex: Int
    private var saveManager = SaveLoadManager()
    private var allImageItems: [ImageItem] = []
    private var currentIndex: Int = 0
    
    init(imageIndex: Int) {
           self.imageIndex = imageIndex
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
        
    private let mainContainerView: UIView = {
        let view = UIView()
//        view.backgroundColor = .red
//        view.alpha = 0.2
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var imageContainer: UIView = {
        let view = UIView()
//        view.backgroundColor = .red
//        view.alpha = 0.6
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
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let imageViewSecond: UIImageView = {
        let image = UIImageView()
//        image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        return image
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
    
    
    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.alpha = 0.6
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let buttonLeft: UIButton = {
        let button = UIButton(type: .system)
        let arrowImage = UIImage(systemName: "arrow.left")
        button.setImage(arrowImage, for: .normal)
        return button
    }()
    
    
    private let buttonRight: UIButton = {
        let button = UIButton(type: .system)
        let arrowImage = UIImage(systemName: "arrow.right")
        button.setImage(arrowImage, for: .normal)
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        return label
    }()
    
    
    private let buttonHeaderContainer: UIView = {
        let view = UIView()
//        view.backgroundColor = .red
//        view.alpha = 0.6
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotifiacations()
        
    }
    
    private func configureUI() {
        view.backgroundColor = .blue
        
     
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
        
        imageContainer.addSubview(imageViewSecond)
        imageViewSecond.snp.makeConstraints { make in
            make.edges.equalTo(photoImage)
        }
        
        
        
        
//        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(photoImageTapped))
//        photoImage.addGestureRecognizer(tapImageGesture)
        
        imageContainer.addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageContainer.snp.bottom)
            make.height.equalToSuperview().multipliedBy(1.0 / 9.0)
        }
        
       
        imageContainer.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.bottom.equalTo(textFiled.snp.top)
            make.centerX.equalToSuperview()
        }
        
        
        mainContainerView.addSubview(buttonContainer)
        buttonContainer.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.right.equalTo(imageContainer)
            make.height.equalToSuperview().dividedBy(20)
        }
        
        buttonContainer.addSubview(buttonLeft)
        buttonLeft.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let actionLeft = UIAction { _ in
            self.buttonLeftFlip() }
        buttonLeft.addAction(actionLeft, for: .touchUpInside)
        
        
        buttonContainer.addSubview(buttonRight)
        buttonRight.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let actionRight = UIAction { _ in
            self.buttonRightFlip()
        }
        buttonRight.addAction(actionRight, for: .touchUpInside)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tapRecognizer)
        
        
        allImageItems = saveManager.loadUserImages()
        guard !allImageItems.isEmpty,
              imageIndex < allImageItems.count else { return }
        
        currentIndex = imageIndex
        
        view.layoutIfNeeded()
        imageViewSecond.frame = CGRect(
            x: photoImage.frame.maxX + 60,
            y: photoImage.frame.minY,
            width: photoImage.frame.width,
            height: photoImage.frame.height
        )
        
        updateUI()
        
        
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
    
//    // - MARK: Load current imag item
//    
//    private func loadCurrentImageItem() {
//       
//        let allImageItems = saveManager.loadUserImages()
//        
//        guard imageIndex < allImageItems.count else {
//            return
//        }
//        let currentImageItem = allImageItems[imageIndex]
//        if let image = saveManager.loadImage(name: currentImageItem.fileName) {
//            photoImage.image = image
//            textFiled.text = currentImageItem.description
//            likeButton.isSelected = currentImageItem.isLiked
//        }
//        
//    }
    
    
    // - MARK: Update UI
    
    private func updateUI() {
        let currentItem = allImageItems[currentIndex]
        
        
        if let image = saveManager.loadImage(name: currentItem.fileName) {
            photoImage.image = image
        }
        
        textFiled.text = currentItem.description
        likeButton.isSelected = currentItem.isLiked
        
        countLabel.text = "\(currentIndex + 1) / \(allImageItems.count)"
        
    }
    
   // - MARK: Flip Left and Right
    
    private func buttonRightFlip() {
        guard !allImageItems.isEmpty else { return }
        let nextIndex = (currentIndex + 1) % allImageItems.count
        let nextItem = allImageItems[nextIndex]
        
        if let nextImage = saveManager.loadImage(name: nextItem.fileName) {
            imageViewSecond.image = nextImage
        }
        
        currentIndex = nextIndex
        
        let centerX = photoImage.frame.midX - imageViewSecond.frame.width / 2
        imageViewSecond.frame.origin.x = view.frame.width
        imageViewSecond.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.imageViewSecond.frame.origin.x = centerX
        } completion: { _ in
            self.photoImage.image = self.imageViewSecond.image
            self.imageViewSecond.frame.origin.x = self.view.frame.width
            self.updateUI()
            
        }
    
    }
    
    private func buttonLeftFlip() {
        guard !allImageItems.isEmpty else { return }
        let prevIndex = (currentIndex - 1 + allImageItems.count) % allImageItems.count
        let prevItem = allImageItems[prevIndex]
        
        imageViewSecond.image = photoImage.image
        let centerX = photoImage.frame.midX - imageViewSecond.frame.width / 2
        imageViewSecond.frame.origin.x = centerX
        imageViewSecond.isHidden = false
        
        currentIndex = prevIndex
        photoImage.image = saveManager.loadImage(name: prevItem.fileName)
        
        UIView.animate(withDuration: 0.5) {
            self.imageViewSecond.frame.origin.x = -self.imageViewSecond.frame.width
        } completion: { _ in
            self.imageViewSecond.frame.origin.x = self.view.frame.width
            self.imageViewSecond.isHidden = true
            self.updateUI()
        }
    }
    
    
    
    

    // - MARK: Back button navigation
    
   private func backButtonPressed() {
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
    
    
    

