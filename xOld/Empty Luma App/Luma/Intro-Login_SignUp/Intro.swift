//
//  Intro.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//


import UIKit
import Parse
import UserNotifications

class Intro: UIViewController {

    /*--- VIEWS ---*/
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var appNameLabel: UILabel!
    

    

    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        if isLoggedIn == true { dismiss(animated: true, completion: nil) }
    }
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        // Layouts
        appNameLabel.text = APP_NAME
        facebookButton.layer.cornerRadius = 22
        signUpButton.layer.cornerRadius = 22
        signUpButton.layer.borderColor = MAIN_COLOR.cgColor
        signUpButton.layer.borderWidth = 2
        loginButton.layer.cornerRadius = 22
        loginButton.layer.borderColor = MAIN_COLOR.cgColor
        loginButton.layer.borderWidth = 2

    }

    
    
    
    
    // ------------------------------------------------
    // FACEBOOK LOGIN BUTTON
    // ------------------------------------------------
    @IBAction func facebookButt(_ sender: Any) {

    }
    
    
    
    // ------------------------------------------------
    // SING UP BUTTON
    // ------------------------------------------------
    @IBAction func signUpButt(_ sender: Any) {
        
        // Sign Up disabled within the app
        // let aVC = storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
        // present(aVC, animated: true, completion: nil)
        
        simpleAlert("Sign up complete")
        isLoggedIn = true
    }
    
    
    
    // ------------------------------------------------
    // LOGIN BUTTON
    // ------------------------------------------------
    @IBAction func loginButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(aVC, animated: true, completion: nil)
    }
    
    
    // ------------------------------------------------
    // TERMS OF SERVICE BUTTON
    // ------------------------------------------------
    @IBAction func tosButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
        present(aVC, animated: true, completion: nil)
    }
    
    
    
    
    // ------------------------------------------------
    // DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButton(_ sender: Any) {
        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        tbc.selectedIndex = 0
        self.present(tbc, animated: false, completion: nil)
    }
    

}// ./ end
