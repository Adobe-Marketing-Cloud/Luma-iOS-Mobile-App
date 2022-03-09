//
//  Preferences.swift
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
import AEPCore
import AEPEdge
import AEPEdgeIdentity
import AEPIdentity

class Preferences: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    /*--- VIEWS ---*/
    @IBOutlet weak var switchEmail: UISwitch!
    @IBOutlet weak var switchPush: UISwitch!
    @IBOutlet weak var switchDirectMail: UISwitch!
    @IBOutlet weak var switchText: UISwitch!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var shippingAddressTxt: UITextField!
    @IBOutlet weak var updateProfileButton: UIButton!
    
    
    var emailLabel = ""
    
    var emailPref  = "out"
    var pushPref = "out"
    var directMailPref = "out"
    var textPref = "out"
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        containerScrollView.isHidden = false
        showUserInfo()
        
        // Adobe Experience Platform - Send XDM Event
        let stateName = "luma: content: ios: us: en: preferences"
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
        phoneNumberTxt.delegate = self
        
        // Init all switches
        switchEmail.isOn = false
        switchDirectMail.isOn = false
        switchPush.isOn = false
        switchText.isOn = false
        
        
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 800)
        updateProfileButton.setTitleColor(UIColor.brown, for: UIControl.State.highlighted)
        
        
        
    }
    
    
    
    // ------------------------------------------------
    // SHOW CURRENT USER INFO
    // ------------------------------------------------
    func showUserInfo() {
        emailLabel = "testuser@gmail.com"
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
    // UPDATE PROFILE BUTTON
    // ------------------------------------------------
    @IBAction func updateProfileButt(_ sender: Any) {
        // Adobe Experience Platform - Send XDM Event
        let actionName = "Update Preferences"
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
        
        // Adobe Experience Platform - Update Identity
        let identityMap: IdentityMap = IdentityMap()
        identityMap.add(item: IdentityItem(id: emailLabel), withNamespace: "Email")
        Identity.updateIdentities(with: identityMap)
    }
    
    
    
    
    // ------------------------------------------------
    // TEXTFIELD DELEGATES
    // ------------------------------------------------
    
    
    @IBAction func emailSwitchIsChanged(myswitch: UISwitch) {
        if myswitch.isOn {
            emailPref = "in"
        } else {
            emailPref = "out"
        }
        print ("email switch ->" + emailPref)
    }
    
    @IBAction func textSwitchIsChanged(myswitch: UISwitch) {
        if myswitch.isOn {
            textPref = "in"
        } else {
            textPref = "out"
        }
        print ("text switch ->" + textPref)
    }
    
    @IBAction func directMailSwitchIsChanged(myswitch: UISwitch) {
        if myswitch.isOn {
            directMailPref = "in"
        } else {
            directMailPref = "out"
        }
        print ("direct mail switch ->" + directMailPref)
    }
    
    @IBAction func pushSwitchIsChanged(myswitch: UISwitch) {
        if myswitch.isOn {
            pushPref = "in"
        } else {
            pushPref = "out"
        }
        print ("push switch ->" + pushPref)
    }
    
    // ------------------------------------------------
    
    // ------------------------------------------------
    // DISMISS KEYBOARD
    // ------------------------------------------------
    func dismissKeyboard() {
        //phoneNumberTxt.resignFirstResponder()
        //emailTxt.resignFirstResponder()
        //fullnameTxt.resignFirstResponder()
        //shippingAddressTxt.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn (_ phoneNumberTxt:UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
}// ./ end

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
