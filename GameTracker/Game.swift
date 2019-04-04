//
//  Game.swift
//  GameTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
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

extension String {
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
}

class Game: Codable, Comparable, CustomStringConvertible {
    var description: String { return name }
    
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
        let freeGames = gamesAndwishes[2]
        
        var tempGames = [Game]()
        
        for gameElements in games {
            //base64 string to NSData
            let decodedData = NSData(base64Encoded: gameElements[2])
            //NSData to UIImage
            let decodedIamge = UIImage(data: decodedData! as Data)
            let done : Bool = gameElements[6] ==  "true" ? true : false
            let tempGame = Game(idgame: gameElements[0], name: gameElements[1], photo: decodedIamge, dord: (gameElements[5] as NSString).integerValue , platform: gameElements[4], done: done, publisher: gameElements[3])
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
        
        
        var tempFreeGames = [GameMember]()
        
        for freeGameElements in freeGames {
            //base64 string to NSData
            let decodedData = NSData(base64Encoded: freeGameElements[2])
            //NSData to UIImage
            let decodedIamge = UIImage(data: decodedData! as Data)
            let tempFreeGame = GameMember(idgamemember: freeGameElements[0], name: freeGameElements[1], photo: decodedIamge, platform: freeGameElements[4], publisher: freeGameElements[3], releasedate: freeGameElements[5])
            tempFreeGames += [tempFreeGame]
        }
        do {
            let data = try PropertyListEncoder().encode(tempFreeGames)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: GameMember.ArchiveURL.path)
            print(success ? "Successful save" : "Save Failed")
        } catch {
            print("Save Failed")
        }
        
        
    }
    
    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func <(lhs: Game, rhs: Game) -> Bool {
        
        /*
        var templhs = lhs.name.lowercased()
        var temprhs = rhs.name.lowercased()
        
        
        //Exclude the le la l' in sort alphabetic result
        //the
        if ( lhs.name.lowercased().hasPrefix("the ") ) {
           templhs =  String(lhs.name[4...])
        }
        if ( rhs.name.lowercased().hasPrefix("the ") ) {
            temprhs =  String(rhs.name[4...])
        }
        
        //le la
        if ( lhs.name.lowercased().hasPrefix("le ") || lhs.name.lowercased().hasPrefix("la ") ) {
            templhs =  String(lhs.name[3...])
        }
        if ( rhs.name.lowercased().hasPrefix("le ") || rhs.name.lowercased().hasPrefix("la ") ) {
            temprhs =  String(rhs.name[3...])
        }
        
        //l'
        if ( lhs.name.lowercased().hasPrefix("l'") ) {
            templhs =  String(lhs.name[2...])
        }
        if ( rhs.name.lowercased().hasPrefix("l'") ) {
            temprhs =  String(rhs.name[2...])
        }
         
        return templhs < temprhs
        */
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}

