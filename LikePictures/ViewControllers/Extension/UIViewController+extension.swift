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
    
       // - MARK: Alert cancel button
    
    func showExitConfirmAlert(
        title: String = "Exit without saving".localized,
        message: String = "Changes will not be saved".localized,
        onExit: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let exitAction = UIAlertAction(title: title, style: .destructive) { _ in
            onExit()
        }
        
        alert.addAction(exitAction)
        
        let stayAction = UIAlertAction(title: "Stay".localized, style: .cancel)
        alert.addAction(stayAction)
        
        present(alert, animated: true)
    }
    
    // - MARK: Alert delete button
    
    func showDeleteConfirmAlert(
        title: String = "Delete image?".localized,
        message: String = "The image and comment will be permanently deleted".localized,
        onDelete: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
            onDelete()
        }
        
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
