//
//  GameTableViewCell.swift
//  GameTracker
//
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var dordLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var idgameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
}
