//
//  GameMember
//  GameTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
//

//import Foundation
import UIKit

class GameMember: Codable, Comparable, CustomStringConvertible {
    var description: String { return name }
    
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var platform: String
    var publisher: String
    var releasedate: String
    var idgamemember: String
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("gamemember")
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey  {
        case idgamemember
        case name
        case photo
        case platform
        case releasedate
        case publisher
    }
    
    // MARK: Initialization
    
    init(idgamemember: String, name: String, photo: UIImage?, platform: String, publisher: String, releasedate: String) {
        // Initialize stored properties.
        self.idgamemember = idgamemember
        self.name = name
        self.photo = photo?.resizeImage(targetSize: CGSize(width: 241, height: 300))
        self.platform = platform
        self.publisher = publisher
        self.releasedate = releasedate
        
        //super.init() // Call superclass initializer
        
        // Initialization should fail if there is no name
        //if name.isEmpty  {
        //  return nil
        //}
    }
    
    // MARK: NSCoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idgamemember, forKey: .idgamemember)
        try container.encode(name, forKey: .name)
        try container.encode(platform, forKey: .platform)
        if let photo = photo, let photoData = UIImagePNGRepresentation(photo) {
            let photoDataBase64String = photoData.base64EncodedString()
            try container.encode(photoDataBase64String, forKey: .photo)
        }
        try container.encode(releasedate, forKey: .releasedate)
        try container.encode(publisher, forKey: .publisher)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idgamemember = try container.decode(String.self, forKey: .idgamemember)
        name = try container.decode(String.self, forKey: .name)
        platform = try container.decode(String.self, forKey: .platform)
        publisher = try container.decode(String.self, forKey: .publisher)
        let photoDataBase64String = try container.decode(String.self, forKey: .photo)
        if let data = Data(base64Encoded: photoDataBase64String) {
            photo = UIImage(data: data)
        } else {
            photo = nil
        }
        releasedate = try container.decode(String.self, forKey: .releasedate)
    }
    
    static func ==(lhs: GameMember, rhs: GameMember) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func <(lhs: GameMember, rhs: GameMember) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "dd MM yyyy"
        
        var component      = DateComponents()
        component.calendar = Calendar.current
        component.year     = 2050
        component.month    = 1
        component.day      = 1
        
        var datelhs : Date = component.date!
        var daterhs : Date = component.date!
        
        if lhs.releasedate != "" {
            datelhs = dateFormatter.date(from: lhs.releasedate)!
        }
        if rhs.releasedate != ""{
            daterhs = dateFormatter.date(from: rhs.releasedate)!
        }
        
        return datelhs < daterhs
    }
}


