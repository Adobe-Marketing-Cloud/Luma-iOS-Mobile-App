//
//  ProductCell.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    /*--- VIEWS ---*/
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var pNameLabel: UILabel!
    @IBOutlet weak var pPriceLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var featuredBadge: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Layout
        self.layer.cornerRadius = 5
    }
    
}
