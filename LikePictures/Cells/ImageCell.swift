
import Foundation
import UIKit
import SnapKit


final class ImageCell: UICollectionViewCell {
    static var identifier: String { "\(Self.self)" }
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.red.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureUI() {
        contentView.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with image: UIImage) {
        userImageView.image = image
    }
}
