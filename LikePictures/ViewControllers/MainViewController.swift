import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    private var isSorted = false
    private var selectedImageIndex: Int? = nil
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.backgroundColor = .systemGray
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    private var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        button.tintColor = .yellow
        return button
    }()
    
    private var systemImagesArray: [UIImage?] = [
        UIImage(systemName: "photo.badge.plus")
    ]
    
    private var saveManager = SaveLoadManager()
    private var userImageItems: [ImageItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserImages()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserImages()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemGray
        
        view.addSubview(sortButton)
        sortButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(44)
        }
        
        let actionSortButton = UIAction { _ in
            self.sortButtonTapped()
        }
        sortButton.addAction(actionSortButton, for: .touchUpInside)
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(sortButton.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    // - MARK: LoadUserImages
    
    private func loadUserImages() {
        let newItems = saveManager.loadUserImages()
        if  newItems.count != userImageItems.count {
            userImageItems = newItems
            collectionView.reloadData()
        }
    }
    
    
    // - MARK: Add Image item to collection
    
    func addImageItem(_ item: ImageItem) {
        userImageItems.append(item)
        saveManager.saveUserImages(userImageItems)
        collectionView.reloadData()
    }
    
    
    // - MARK: SortButtton tap
    
    @objc private func sortButtonTapped() {
        sortImages()
    }
    
    // - MARK: Sort images
    
    private func sortImages() {
        isSorted.toggle()
        
        if isSorted {
            userImageItems.sort { item1, item2 in
                if item1.isLiked && !item2.isLiked {
                    return true
                } else if !item1.isLiked && item2.isLiked {
                    return false
                }
                return false
            }
            
        } else {
            userImageItems.sort { $0.fileName < $1.fileName }
        }
        
        saveManager.saveUserImages(userImageItems)
        collectionView.reloadData()
    }
    
    
    
    // - MARK: AddImageViewController transfer
    
    private func showAddImageViewController() {
        let addImageViewController = AddImageViewController()
        navigationController?.pushViewController(addImageViewController, animated: true )
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + userImageItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == 0 {
            if let systemImage = systemImagesArray[0]  {
                cell.configure(with: systemImage)
            }
        } else {
            let userImageIndex = indexPath.item - 1
            let item = userImageItems[userImageIndex]
            if let image = saveManager.loadImage(name: item.fileName) {
                cell.configure(with: image)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, 
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / CGFloat(4)
        let height = (width / 4) * 3
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            showAddImageViewController()
            return
        }
        
        let imageIndex = indexPath.item - 1
        
        clearAllSelectionBorders()
        
        if selectedImageIndex == imageIndex {
            let editViewController = EditImages(imageIndex: imageIndex)
            navigationController?.pushViewController(editViewController, animated: true)
            selectedImageIndex = nil
        } else {
            selectedImageIndex = imageIndex
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 4
            cell?.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard indexPath.item >= 1 else { return }
        
        collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 4
        collectionView.cellForItem(at: indexPath)?.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    
    func clearAllSelectionBorders() {
        for i in 1..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: i, section: 0)
            collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 0
            collectionView.cellForItem(at: indexPath)?.layer.borderColor = UIColor.black.cgColor
        }
    }
    
}
