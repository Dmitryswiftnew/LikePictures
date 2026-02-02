import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
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
        view.backgroundColor = .yellow
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(100)
        }
        
        
    }
    
    // - MARK: LoadUserImages
    
    private func loadUserImages() {
        let newItems = saveManager.loadUserImages()
        if  newItems.count != userImageItems.count {
            userImageItems = newItems
            collectionView.reloadData()
            print("🔄 MainVC: Загружено \(userImageItems.count) изображений")
        }
    }
    
    
    // - MARK: Add Image item to collection
    
    func addImageItem(_ item: ImageItem) {
        userImageItems.append(item)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {  // временно
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + userImageItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        if indexPath.item < systemImagesArray.count {
            if let systemImage = systemImagesArray[indexPath.item]  {
                cell.configure(with: systemImage)
            }
        } else {
            let userImageIndex = indexPath.item - systemImagesArray.count
            let item = userImageItems[userImageIndex]
            if let image = saveManager.loadImage(name: item.fileName) {
                cell.configure(with: image)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / CGFloat(3)
        let height = (width / 4) * 3
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < systemImagesArray.count {
            showAddImageViewController()
        } else {
            let imageIndex = indexPath.item - systemImagesArray.count
            let editViewController = EditImages(imageIndex: imageIndex)
            navigationController?.pushViewController(editViewController, animated: true)
        }
    }
    
}
