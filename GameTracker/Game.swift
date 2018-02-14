//
//  Game.swift
//  GameTracker
//
//

//import Foundation
import UIKit

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

class Game: Codable {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var dord: Int
    var platform: String
    var publisher: String
    var done: Bool
    var idgame: String
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("games")
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey  {
        case idgame
        case name
        case photo
        case platform
        case dord
        case done
        case publisher
    }
    
    // MARK: Initialization
    
    init(idgame: String, name: String, photo: UIImage?, dord: Int, platform: String, done: Bool, publisher: String) {
        // Initialize stored properties.
        self.idgame = idgame
        self.name = name
        self.photo = photo?.resizeImage(targetSize: CGSize(width: 241, height: 300))
        self.dord = dord
        self.platform = platform
        self.publisher = publisher
        self.done = done
        
        //super.init() // Call superclass initializer
        
        // Initialization should fail if there is no name
        //if name.isEmpty  {
        //  return nil
        //}
    }
    
    // MARK: NSCoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idgame, forKey: .idgame)
        try container.encode(name, forKey: .name)
        try container.encode(platform, forKey: .platform)
        if let photo = photo, let photoData = UIImagePNGRepresentation(photo) {
            let photoDataBase64String = photoData.base64EncodedString()
            try container.encode(photoDataBase64String, forKey: .photo)
        }
        try container.encode(dord, forKey: .dord)
        try container.encode(done, forKey: .done)
        try container.encode(publisher, forKey: .publisher)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idgame = try container.decode(String.self, forKey: .idgame)
        name = try container.decode(String.self, forKey: .name)
        platform = try container.decode(String.self, forKey: .platform)
        publisher = try container.decode(String.self, forKey: .publisher)
        let photoDataBase64String = try container.decode(String.self, forKey: .photo)
        if let data = Data(base64Encoded: photoDataBase64String) {
            photo = UIImage(data: data)
        } else {
            photo = nil
        }
        dord = try container.decode(Int.self, forKey: .dord)
        done = try container.decode(Bool.self, forKey: .done)
    }
    
    static func importData(from url: URL) {
        guard let dictionary = NSArray(contentsOf: url),
            let gamesAndwishes = dictionary as? [[[String]]] else {
                return
        }
        let games = gamesAndwishes[0]
        let wishes = gamesAndwishes[1]
        
        var tempGames = [Game]()
        
        for gameElements in games {
            //base64 string to NSData
            let decodedData = NSData(base64Encoded: gameElements[2])
            //NSData to UIImage
            let decodedIamge = UIImage(data: decodedData! as Data)
            let done : Bool = gameElements[6] ==  "true" ? true : false
            let tempGame = Game(idgame: gameElements[0], name: gameElements[1], photo: decodedIamge, dord: (gameElements[6] as NSString).integerValue , platform: gameElements[4], done: done, publisher: gameElements[3])
            tempGames += [tempGame]
        }
        do {
            let data = try PropertyListEncoder().encode(tempGames)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: Game.ArchiveURL.path)
            print(success ? "Successful save" : "Save Failed")
        } catch {
            print("Save Failed")
        }
        
        var tempWishes = [Wish]()
        
        for wishElements in wishes {
            //base64 string to NSData
            let decodedData = NSData(base64Encoded: wishElements[2])
            //NSData to UIImage
            let decodedIamge = UIImage(data: decodedData! as Data)
            let buy : Bool = wishElements[6] ==  "true" ? true : false
            let tempWish = Wish(idwish: wishElements[0], name: wishElements[1], photo: decodedIamge, platform: wishElements[4], buy: buy, publisher: wishElements[3], releasedate: wishElements[5])
            tempWishes += [tempWish]
        }
        do {
            let data = try PropertyListEncoder().encode(tempWishes)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: Wish.ArchiveURL.path)
            print(success ? "Successful save" : "Save Failed")
        } catch {
            print("Save Failed")
        }
        //Force reset by crash //TODO fix that
        UIApplication.shared.keyWindow?.rootViewController = TabBarController()
    }
}

