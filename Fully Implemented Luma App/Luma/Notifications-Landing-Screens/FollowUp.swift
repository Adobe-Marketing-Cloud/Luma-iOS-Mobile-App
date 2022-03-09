//
//  FollowUp.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import Foundation
import UIKit
import Parse
import UserNotifications

import Alamofire
import SwiftyJSON



class FollowUp: UIViewController {
    
    @IBOutlet weak var firstItemLabel: UILabel!
    @IBOutlet weak var secItemLabel: UILabel!
    @IBOutlet weak var thirdItemLabel: UILabel!
    @IBOutlet weak var firstPriceLabel: UILabel!
    @IBOutlet weak var secPriceLabel: UILabel!
    @IBOutlet weak var thirdPriceLabel: UILabel!
    @IBOutlet weak var firstItemImg: UIImageView!
    @IBOutlet weak var secItemImg: UIImageView!
    @IBOutlet weak var thirdItemImg: UIImageView!
    
    var userEmail = ""
    
    @IBAction func dismissButt(_ sender: Any) {
        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        tbc.selectedIndex = 0
        self.present(tbc, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            //containerScrollView.isHidden = false
            showUserInfo()
            
        } else {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "Offers")
            present(vc!, animated: true, completion: nil)
        }
    }
    
    func showUserInfo() {
        self.showHUD()
//        let currentUser = PFUser.current()!
//
//        // Email
//        userEmail = "\(currentUser[USER_EMAIL]!)"
//        showEEInfo()
    }
    
    
    func showEEInfo() {

    }
    
    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
