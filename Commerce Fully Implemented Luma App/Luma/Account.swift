//
//  Account.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import UserNotifications

import Alamofire
import SwiftyJSON

//Adobe AEP SDKs
import AEPEdge
import AEPCore
import AEPEdgeIdentity
import AEPUserProfile

class Account: UIViewController {
    
    /*--- VIEWS ---*/
    @IBOutlet weak var myOrdersButton: UIButton!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var shippingAddressLabel: UILabel!
    @IBOutlet weak var ecidLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var loyaltyLevelLabel: UILabel!
    @IBOutlet weak var loyaltyPointsLabel: UILabel!
    @IBOutlet weak var firstItemLabel: UILabel!
    @IBOutlet weak var secItemLabel: UILabel!
    @IBOutlet weak var thirdItemLabel: UILabel!
    @IBOutlet weak var firstPriceLabel: UILabel!
    @IBOutlet weak var secPriceLabel: UILabel!
    @IBOutlet weak var thirdPriceLabel: UILabel!
    @IBOutlet weak var firstItemImg: UIImageView!
    @IBOutlet weak var secItemImg: UIImageView!
    @IBOutlet weak var thirdItemImg: UIImageView!
    var ecid = ""

    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        containerScrollView.isHidden = false
        if(isLoggedIn == true){
            showUserInfo()
        }else {
            containerScrollView.isHidden = true
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
        }
        
        // Adobe Experience Platform - Send XDM Event
        let stateName = "luma: content: ios: us: en: profile"
        var xdmData: [String: Any] = [:]
        //Page View
        xdmData["_techmarketingdemos"] = [
            "appInformation": [
                "appStateDetails": [
                    "screenType": "App",
                    "screenName": stateName,
                    "screenView": [
                        "value": 1
                    ]
                ]
            ]
        ]
        let experienceEvent = ExperienceEvent(xdm: xdmData)
        Edge.sendEvent(experienceEvent: experienceEvent)

    }
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layouts
        myOrdersButton.layer.cornerRadius = 8
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 965)
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        
        
        // Adding Refresh when pulling down
        containerScrollView.refreshControl = UIRefreshControl()
        containerScrollView.refreshControl?.addTarget(self, action: #selector(showUserInfo), for: .valueChanged)
        containerScrollView.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing ...")

    }
    
    
    
    
    // ------------------------------------------------
    // SHOW CURRENT USER INFO
    // ------------------------------------------------
    @objc func showUserInfo() {
        let loyaltyLevel = "Gold Tier"
        usernameLabel.text = "userName"
        emailLabel.text = "testuser@gmail.com"
        self.firstNameLabel.text = "Jane"
        self.lastNameLabel.text = "Smith"
        self.genderLabel.text = "F"
        self.shippingAddressLabel.text = "123 N Main St., Portland OR, 97213"
        self.loyaltyLevelLabel.text = loyaltyLevel

        // Adobe Experience Platform - Update User Profile
        var profileMap = [String: Any]()
        profileMap["loyaltyLevel"] = loyaltyLevel
        UserProfile.updateUserAttributes(attributeDict: profileMap)
        
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
    
    // ------------------------------------------------
    // MY ORDERS BUTTON
    // ------------------------------------------------
    @IBAction func myOrdersButt(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Orders") as! Orders
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    // ------------------------------------------------
    // OPTIONS BUTTON
    // ------------------------------------------------
    @IBAction func optionsButt(_ sender: AnyObject) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Select Option",
                                      preferredStyle: .alert)
        
        // Logout
        let logout = UIAlertAction(title: "Logout", style: .destructive, handler: { (action) -> Void in
            isLoggedIn = false;
            
            // Adobe Experience Platform - Send XDM Event
            let actionName = "Logout"
            var xdmData: [String: Any] = [:]
            //Page View
            xdmData["_techmarketingdemos"] = [
                "appInformation": [
                    "appInteraction": [
                        "name": actionName,
                        "appAction": [
                            "value": 1
                        ]
                    ]
                ]
            ]
            let experienceEvent = ExperienceEvent(xdm: xdmData)
            Edge.sendEvent(experienceEvent: experienceEvent)
            
            // Adobe Experience Platform - Remove Identity
            /*
             Remove the identity from the stored client-side IdentityMap. The Identity extension will stop sending the identifier to the Edge Network. Using this API does not remove the identifier from the server-side User Profile Graph or Identity Graph.
             */
            
            let emailAddress = "testuser@gmail.com"
            let crmId = "112ca06ed53d3db37e4cea49cc45b71e"
            // Adobe Experience Platform - Remove Identity
            Identity.removeIdentity(item: IdentityItem(id: emailAddress), withNamespace: "Email")
            Identity.removeIdentity(item: IdentityItem(id: crmId), withNamespace: "lumaCrmId")
        })
        
        let editPreferences = UIAlertAction(title: "Edit Channel Preferences", style: .default, handler: { (action) -> Void in
            self.showHUD()
            let editPreferences = self.storyboard?.instantiateViewController(withIdentifier: "EditPreferences") as! Preferences
            self.navigationController?.pushViewController(editPreferences, animated: true)
            //self.present(editPreferences, animated: false, completion: nil)
            //self.hideHUD()
        })
 
        let editStore = UIAlertAction(title: "Edit Store Preferences", style: .default, handler: { (action) -> Void in
            self.showHUD()
            let editPreferences = self.storyboard?.instantiateViewController(withIdentifier: "EditStore") as! StoreSelection
            self.navigationController?.pushViewController(editPreferences, animated: true)
            //self.present(editPreferences, animated: false, completion: nil)
            //self.hideHUD()
        })

        
        
        alert.addAction(editPreferences)
        alert.addAction(editStore)
        alert.addAction(logout)
        
        // Cancel
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}// ./ end
