//
//  Login.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//


import UIKit
import Parse
import UserNotifications

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class Login: UIViewController, UITextFieldDelegate {
    
    /*--- VIEWS ---*/
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var loginButtons: [UIButton]!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    var emailTxt: String = ""
    
    
    
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        // Layouts
        loginLabel.text = "Log in to \(APP_NAME)"
        loginButton.layer.cornerRadius = 22
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)

    }
    
    
    
    
    // ------------------------------------------------
    // LOGIN BUTTON
    // ------------------------------------------------
    @IBAction func loginButt(_ sender: AnyObject) {
        dismissKeyboard()
        isLoggedIn = true;
        //simpleAlert("Sign in success")
        //containerScrollView.isHidden = true
        self.hideHUD()
        self.dismiss(animated: true, completion: nil)
        self.emailTxt = "testUser@gmail.com"
    }
    
    
    
    

    
    
    // ------------------------------------------------
    // SIGNUP BUTTON
    // ------------------------------------------------
    @IBAction func signupButt(_ sender: AnyObject) {
        
        simpleAlert("Signup complete")
    }
    
    
    
    
    
    // ------------------------------------------------
    // TEXTFIELD DELEGATES
    // ------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
        if textField == passwordTxt  {
            passwordTxt.resignFirstResponder()
            loginButt(self)
        }
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
    }


    
    
    
    
    
    // ------------------------------------------------
    // FORGOT PASSWORD BUTTON
    // ------------------------------------------------
    @IBAction func forgotPasswButt(_ sender: AnyObject) {
        simpleAlert("Forgot Password Complete")
    }


    
    // ------------------------------------------------
    // DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
    
    func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    }
