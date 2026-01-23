

import Foundation
import SnapKit
import UIKit


final class AddImageViewController: UIViewController  {
    
    private let mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.alpha = 0.2
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var buttonBack: UIButton = {
        let button = UIButton(type: .system)
        let backImage = UIImage(systemName: "chevron.left")
        button.setImage(backImage, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .green
        
        
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        
        view.addSubview(buttonBack)
        buttonBack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(40)
        }
        
    }
    
    
}

