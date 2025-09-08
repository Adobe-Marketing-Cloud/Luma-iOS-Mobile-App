//
//  Receipt.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import Foundation
import UIKit
import UserNotifications


class Receipt: UIViewController {
    
    @IBAction func dismissButt(_ sender: Any) {
        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        tbc.selectedIndex = 0
        //self.present(tbc, animated: false, completion: nil)
    }
    
    
    
}
