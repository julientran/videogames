//
//  Wish
//  WishTracker
//
//

//import Foundation
import UIKit

class Wish: Codable {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    //var dord: Int
    var platform: String
    var publisher: String
    //TODO
    var buy: Bool
    var idwish: String
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("wishes")
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey  {
        case idwish
        case name
        case photo
        case platform
        //TODO
        //case dord
        case buy
        case publisher
    }
    
    // MARK: Initialization
    
    //TODO
    init(idwish: String, name: String, photo: UIImage?, platform: String, buy: Bool, publisher: String) {
        // Initialize stored properties.
        self.idwish = idwish
        self.name = name
        self.photo = photo?.resizeImage(targetSize: CGSize(width: 241, height: 300))
        //self.dord = dord
        self.platform = platform
        self.publisher = publisher
        //TODO
        self.buy = buy
        
        //super.init() // Call superclass initializer
        
        // Initialization should fail if there is no name
        //if name.isEmpty  {
        //  return nil
        //}
    }
    
    // MARK: NSCoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idwish, forKey: .idwish)
        try container.encode(name, forKey: .name)
        try container.encode(platform, forKey: .platform)
        if let photo = photo, let photoData = UIImagePNGRepresentation(photo) {
            let photoDataBase64String = photoData.base64EncodedString()
            try container.encode(photoDataBase64String, forKey: .photo)
        }
        //TODO
        //try container.encode(dord, forKey: .dord)
        try container.encode(buy, forKey: .buy)
        try container.encode(publisher, forKey: .publisher)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idwish = try container.decode(String.self, forKey: .idwish)
        name = try container.decode(String.self, forKey: .name)
        platform = try container.decode(String.self, forKey: .platform)
        publisher = try container.decode(String.self, forKey: .publisher)
        let photoDataBase64String = try container.decode(String.self, forKey: .photo)
        if let data = Data(base64Encoded: photoDataBase64String) {
            photo = UIImage(data: data)
        } else {
            photo = nil
        }
        //TODO
        //dord = try container.decode(Int.self, forKey: .dord)
        buy = try container.decode(Bool.self, forKey: .buy)
    }
}


