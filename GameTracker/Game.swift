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

class Game: NSObject, /* protocol */ NSCoding {

  // MARK: Properties

  var name: String
  var photo: UIImage?
  var dord: Int
  var platform: String
  var publisher: String
  var done: Bool
  var idgame: String
  //var rating: Int

  // MARK: Archiving Paths

  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("games")

  // MARK: Types

  struct PropertyKey {
    static let idgameKey = "idgame"
    static let nameKey = "name"
    static let photoKey = "photo"
    static let platformKey = "platform"
    static let dordKey = "dord"
    static let doneKey = "done"
    static let publisherKey = "publisher"
    
    //static let ratingKey = "rating"
  }

  // MARK: Initialization

    init?(idgame: String, name: String, photo: UIImage?, dord: Int, platform: String, done: Bool, publisher: String) {
  //init?(name: String, photo: UIImage?, rating: Int) {
    // Initialize stored properties.
    self.idgame = idgame
    self.name = name
    self.photo = photo?.resizeImage(targetSize: CGSize(width: 241, height: 300))
    self.dord = dord
    self.platform = platform
    self.publisher = publisher
    self.done = done
    //self.rating = rating

    super.init() // Call superclass initializer

    // Initialization should fail if there is no name or if the rating is out of range.
    //if name.isEmpty || rating < 0 || rating > 5 {
    //  return nil
    //}
  }

  // MARK: NSCoding

  func encode(with aCoder: NSCoder) {
    aCoder.encode(idgame, forKey: PropertyKey.idgameKey)
    aCoder.encode(name, forKey: PropertyKey.nameKey)
    aCoder.encode(platform, forKey: PropertyKey.platformKey)
    aCoder.encode(photo, forKey: PropertyKey.photoKey)
    aCoder.encode(dord, forKey: PropertyKey.dordKey)
    aCoder.encode(done, forKey: PropertyKey.doneKey)
    aCoder.encode(publisher, forKey: PropertyKey.publisherKey)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    let idgame = aDecoder.decodeObject(forKey: PropertyKey.idgameKey) as! String
    let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
    let platform = aDecoder.decodeObject(forKey: PropertyKey.platformKey) as! String
    let publisher = aDecoder.decodeObject(forKey: PropertyKey.publisherKey) as! String
    // Because photo is an optional property of Game, use conditional cast.
    let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
    //let rating = aDecoder.decodeInteger(forKey: PropertyKey.ratingKey)
    let dord = aDecoder.decodeInteger(forKey: PropertyKey.dordKey)
    let done = aDecoder.decodeBool(forKey: PropertyKey.doneKey)
    // Must call designated initializer.
    self.init(idgame:idgame, name: name, photo: photo, dord: dord, platform: platform, done: done, publisher: publisher)
  }

}
