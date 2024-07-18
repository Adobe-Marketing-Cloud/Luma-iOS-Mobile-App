//
//  SignUp.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//


import UIKit
import Parse
import UserNotifications

//Adobe AEP SDKs
import AEPEdge
import AEPCore
import AEPEdgeIdentity

class SignUp: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /*--- VIEWS ---*/
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var checkboxButton: UIButton!
    

    
    /*--- VARIABLES ---*/
    var tosAccepted = false
    
    
    

    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        // Layouts
        signUpButton.layer.cornerRadius = 22
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 750)
    }
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        // Adobe Experience Platform - Send XDM Event
        //Prep Data
        let stateName = "luma: content: ios: us: en: sign up"
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
    // SIGNUP BUTTON
    // ------------------------------------------------
    @IBAction func signupButt(_ sender: AnyObject) {
        
        // Adobe Experience Platform - Update Identity Map
        let identityMap: IdentityMap = IdentityMap()
        identityMap.add(item: IdentityItem(id: "\(emailTxt.text!)"), withNamespace: "Email")
        Identity.updateIdentities(with: identityMap)
        
        
        // Adobe Experience Platform - Send XDM Event
        let actionName = "Sign Up"
        var xdmData: [String: Any] = [:]
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
       
    }
    
    
    
    
    
    // ------------------------------------------------
    // CHECKBOX BUTTON
    // ------------------------------------------------
    @IBAction func checkboxButt(_ sender: UIButton) {
        tosAccepted = true
        sender.setBackgroundImage(UIImage(named: "checkbox_on"), for: .normal)
    }
    
    
    
    
    // ------------------------------------------------
    // TEXTFIELD DELEGATE
    // ------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
        if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
        if textField == emailTxt {  fullnameTxt.becomeFirstResponder()     }
        if textField == fullnameTxt {  dismissKeyboard()  }
    return true
    }
    
    
    
    
    // ------------------------------------------------
    // TAP TO DISMISS KEYBOARD
    // ------------------------------------------------
    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
    }
    
    
    

    // ------------------------------------------------
    // DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    

    // ------------------------------------------------
    // TERMS OF SERVICE BUTTON
    // ------------------------------------------------
    @IBAction func tosButt(_ sender: AnyObject) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
        present(aVC, animated: true, completion: nil)
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    }
