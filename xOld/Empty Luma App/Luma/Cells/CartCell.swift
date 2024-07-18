//
//  CartCell.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit

class CartCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var pNameLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var pPriceLabel: UILabel!
    @IBOutlet weak var removeProductButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Layout
        pImage.layer.cornerRadius = 5
        minusButton.layer.cornerRadius = 5
        plusButton.layer.cornerRadius = 5
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
