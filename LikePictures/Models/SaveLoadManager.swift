import Foundation
import  UIKit
import KeychainSwift

final class SaveLoadManager {
    
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
    
}

