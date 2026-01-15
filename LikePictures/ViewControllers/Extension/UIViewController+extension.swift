
import UIKit

extension UIViewController {
    
    func showErrorAlert(title: String, message: String = "") {
        let alert = UIAlertController(title: title,
                                      message: message.isEmpty ? nil : message,
                                      preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    
    
}
