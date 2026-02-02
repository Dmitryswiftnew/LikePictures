
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
        title: String = "Выйти без сохранения",
        message: String = "Изменения не будут сохранены",
        onExit: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let exitAction = UIAlertAction(title: title, style: .destructive) { _ in
            onExit()
        }
        
        alert.addAction(exitAction)
        
        let stayAction = UIAlertAction(title: "Остаться", style: .cancel)
        alert.addAction(stayAction)
        
        present(alert, animated: true)
        
    }
    
    // - MARK: Alert delete button
    
    func showDeleteConfirmAlert(
        title: String = "Удалить изображение?",
        message: String = "Картинка и комментарий будут удалены навсегда",
        onDelete: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            onDelete()
        }
        
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

}
