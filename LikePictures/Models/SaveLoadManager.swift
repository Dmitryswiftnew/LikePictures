import Foundation
import  UIKit
import KeychainSwift


enum Keys: String {
    case imageKey
}

final class SaveLoadManager {
    
    private let defaults = UserDefaults.standard
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // - MARK: Password
    
    func savePassword(_ password: String) {
        let keychain = KeychainSwift()
        keychain.set(password, forKey: KeychainKeys.myPassword.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.myFlag.rawValue)
    }
    
    func loadPassword() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(KeychainKeys.myPassword.rawValue)
    }
    
    
    func isPasswordCreated() -> Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.myFlag.rawValue)
    }
    
    func resetPassword() {
        let keychain = KeychainSwift()
        keychain.delete(KeychainKeys.myPassword.rawValue)
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.myFlag.rawValue)
    }
    
    // - MARK: Image
    func saveImage(image: UIImage) -> String? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil }
        let fileName = UUID().uuidString
        let fileURL = directory.appendingPathComponent(fileName)
        guard let data = image.pngData() else { return nil }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    func loadImage(name: String) -> UIImage? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = directory.appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    
    // - MARK: ImageItem
    
    func saveUserImages(_ images: [ImageItem]) {
        defaults.set(encodable: images, forKey: Keys.imageKey.rawValue)
    }
    
    func loadUserImages() -> [ImageItem] {
        defaults.get(decodableType: [ImageItem].self, forKey: Keys.imageKey.rawValue) ?? [] 
    }
    
    // - MARK: Delete image and description 
    
    func deleteImage(at index: Int, from items: inout [ImageItem]) {
        guard index < items.count else { return }
        
        let itemToDelete = items[index]
        
        let filePath = documentsDirectory.appendingPathComponent(itemToDelete.fileName)
        try? FileManager.default.removeItem(at: filePath)
        
        items.remove(at: index)
        
        saveUserImages(items)
    }
    
    
    
}

