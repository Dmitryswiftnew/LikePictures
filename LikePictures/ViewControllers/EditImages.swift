
import Foundation
import UIKit
import SnapKit
import AudioToolbox

final class EditImages: UIViewController {
    
    private var centerYConstraint: Constraint?
    private var imageIndex: Int
    private var saveManager = SaveLoadManager()
    private var allImageItems: [ImageItem] = []
    private var currentIndex: Int = 0
    private var isZoomed = false
    private var originalFrame: CGRect = .zero
    private var dismissTapGesture: UITapGestureRecognizer?
    
    init(imageIndex: Int) {
           self.imageIndex = imageIndex
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
        
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
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let imageViewSecond: UIImageView = {
        let image = UIImageView()
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
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let trashImage = UIImage(systemName: "trash")
        button.setImage(trashImage, for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotifiacations()
        
    }
    
    // - MARK: Configure UI
    
    
    private func configureUI() {
        view.backgroundColor = .lightGray
        
     
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
        
        photoImage.addSubview(imageViewSecond)
        imageViewSecond.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageViewSecond.isHidden = true
        
        
        imageContainer.addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageContainer.snp.bottom)
            make.height.equalToSuperview().multipliedBy(1.0 / 9.0)
        }
        
       
        imageContainer.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(photoImage.snp.bottom)
            make.bottom.equalTo(textFiled.snp.top)
            make.height.equalToSuperview().dividedBy(20)
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
        
        buttonContainer.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        
        let deleteAction = UIAction { _ in
            self.showDeleteConfirmAlert {
                self.deleteCurrentImage()
                AudioServicesPlaySystemSound(1075)
            }
        }
        
        deleteButton.addAction(deleteAction, for: .touchUpInside)
        
        
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(photoImageTapped))
        tapImageGesture.numberOfTapsRequired = 2
        photoImage.addGestureRecognizer(tapImageGesture)
   
        let actionLeft = UIAction { _ in
            self.buttonLeftFlip() }
        buttonLeft.addAction(actionLeft, for: .touchUpInside)
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(buttonLeftFlip))
        leftSwipeRecognizer.direction = .left
        photoImage.addGestureRecognizer(leftSwipeRecognizer)
        
        
        
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
        
        
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(buttonRightFlip))
        rightSwipeRecognizer.direction = .right
        photoImage.addGestureRecognizer(rightSwipeRecognizer)
        
        
    
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
    
    @objc private func buttonRightFlip() {
        imageViewSecond.isHidden = false
        imageContainer.bringSubviewToFront(imageViewSecond)
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
    
    @objc private func buttonLeftFlip() {
        imageViewSecond.isHidden = false
        imageContainer.bringSubviewToFront(imageViewSecond)
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
    
    // - MARK: Update current image
    
    private func updateCurrentImageItem() {
        guard !allImageItems.isEmpty else { return }
        let currentItem = allImageItems[currentIndex]
        
        currentItem.description = textFiled.text?.isEmpty != true ? textFiled.text : nil
        currentItem.isLiked = likeButton.isSelected
        
        allImageItems[currentIndex] = currentItem
        
        saveManager.saveUserImages(allImageItems)
    }
    
    // - MARK: Zoom image
    
    @objc private func photoImageTapped() {
        if isZoomed {
            zoomOut()
        } else {
            zoomIn()
        }
    }
    
    
    private func zoomIn() {
        originalFrame = photoImage.convert(photoImage.bounds, to: view)
        
        mainContainerView.bringSubviewToFront(imageContainer)
        imageContainer.bringSubviewToFront(photoImage)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.photoImage.frame = self.view.bounds.insetBy(dx: 0, dy: 20)
            self.photoImage.contentMode = .scaleAspectFill
            self.photoImage.layer.cornerRadius = 0
            self.photoImage.layer.masksToBounds = false
            self.view.backgroundColor = .black
        })
        
        buttonHeaderContainer.isHidden = true
        buttonContainer.isHidden = true
        textFiled.isHidden = true
        countLabel.isHidden = true
        
        
        addDismissGesture()
        isZoomed = true
        
        
    }
    
    private func zoomOut() {
        UIView.animate(withDuration: 0.3, animations:  {
            self.photoImage.frame = self.originalFrame
            self.photoImage.contentMode = .scaleAspectFill
            self.photoImage.layer.cornerRadius = 0
            self.photoImage.layer.masksToBounds = true
            self.photoImage.backgroundColor = .lightGray
            self.view.backgroundColor = .lightGray
            
        }) { _ in
            
            self.buttonHeaderContainer.isHidden = false
            self.buttonContainer.isHidden = false
            self.textFiled.isHidden = false
            self.countLabel.isHidden = false
            self.imageContainer.isHidden = false
            
            self.imageContainer.bringSubviewToFront(self.photoImage)
            self.imageViewSecond.isHidden = true
            
            
            self.photoImage.snp.makeConstraints { make in
                make.top.equalTo(self.imageContainer.snp.top)
                make.left.right.equalToSuperview()
                make.height.equalTo(self.photoImage.snp.width).multipliedBy(0.95)
            }
            
            self.view.layoutIfNeeded()
        }
        
        removeDismissGesture()
        isZoomed = false
    }
    
    
    private func addDismissGesture() {
        dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissZoom))
        dismissTapGesture.map { view.addGestureRecognizer($0) }
    }
    
    private func removeDismissGesture() {
        if let dismissGesture = dismissTapGesture {
            view.removeGestureRecognizer(dismissGesture)
            dismissTapGesture = nil
        }
    }
    
    @objc private func dismissZoom() {
        zoomOut()
    }
    
    
    // - MARK: Delete current image
    
    private func deleteCurrentImage() {
        saveManager.deleteImage(at: currentIndex, from: &allImageItems)
        
        if allImageItems.isEmpty {
            navigationController?.popViewController(animated: true)
            return
        }
        
        currentIndex = min(currentIndex, allImageItems.count - 1)
        animateDeleteLeft {
            self.updateUI()
        }
    }
    
    
    private func animateDeleteLeft(completion: @escaping () -> Void) {
        let centerX = photoImage.frame.midX - imageViewSecond.frame.width / 2
        
        let nextItem = allImageItems[currentIndex]
        if let nextImage = saveManager.loadImage(name: nextItem.fileName) {
            imageViewSecond.image = nextImage
        }
        imageViewSecond.frame.origin.x = centerX
        imageViewSecond.isHidden = false
        
        
        UIView.animate(withDuration: 0.4) {
            self.photoImage.frame.origin.x = -self.photoImage.frame.width
        } completion: { _ in
            self.photoImage.frame.origin.x = centerX
            self.photoImage.image = self.imageViewSecond.image
            self.imageViewSecond.frame.origin.x = self.view.frame.width
            self.imageViewSecond.isHidden = true
            completion()
        }
    }
    

    // - MARK: Back button navigation
    
   private func backButtonPressed() {
       updateCurrentImageItem()
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
    
    
    

