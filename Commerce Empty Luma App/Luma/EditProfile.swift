//
//  EditProfile.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import UserNotifications

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    /*--- VIEWS ---*/
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var shippingAddressTxt: UITextField!
    @IBOutlet weak var updateProfileButton: UIButton!
    
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 800)
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        updateProfileButton.layer.cornerRadius = 8
        
        
        // Call query
        showUserInfo()
    }
    
    
    
    // ------------------------------------------------
    // SHOW CURRENT USER INFO
    // ------------------------------------------------
    func showUserInfo() {
        usernameTxt.text = "userName"
        fullnameTxt.text = "Jane Smith"
        emailTxt.text = "testuser@gmail.com"
        shippingAddressTxt.text = "123 N Main St., Portland OR, 97213"
    }
    
    
    // ------------------------------------------------
    // CHANGE AVATAR PHOTO BUTTON
    // ------------------------------------------------
    @IBAction func changePhotoButt(_ sender: Any) {

    }
    
    // ------------------------------------------------
    // IMAGE PICKER DELEGATE
    // ------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

    }
    
    
    
    
    
    // ------------------------------------------------
    // UPDATE PROFILE BUTTON
    // ------------------------------------------------
    @IBAction func updateProfileButt(_ sender: Any) {

    }
    
    
    
    
    // ------------------------------------------------
    // TEXTFIELD DELEGATES
    // ------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    
    // ------------------------------------------------
    // DISMISS KEYBOARD
    // ------------------------------------------------
    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
        shippingAddressTxt.resignFirstResponder()
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
