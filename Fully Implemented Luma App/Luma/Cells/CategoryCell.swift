//
//  CategoryCell.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit

class CategoryCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var catImage: UIImageView!
    @IBOutlet weak var catName: UILabel!
    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Layout
        catImage.layer.cornerRadius = 8
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
