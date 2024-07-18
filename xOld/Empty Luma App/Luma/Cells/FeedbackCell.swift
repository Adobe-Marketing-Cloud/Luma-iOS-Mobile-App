//
//  FeedbackCell.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit

class FeedbackCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var starImg: UIImageView!
    @IBOutlet weak var feedbackTxt: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Layout
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
