
import Foundation

final class ImageItem: Codable {
    let id: String
    let fileName: String
    let description: String?
    var isLiked: Bool
    
    init(id: String, fileName: String, description: String?, isLiked: Bool) {
        self.id = id
        self.fileName = fileName
        self.description = description
        self.isLiked = isLiked
    }
    
}
