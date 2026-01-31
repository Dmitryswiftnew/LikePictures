
import Foundation


extension UserDefaults {
    
    func set<T: Encodable>(encodable: T?, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func get<T: Decodable>(decodableType: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(decodableType, from: data)
    }
    
    
}
