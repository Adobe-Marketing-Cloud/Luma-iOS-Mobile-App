//
//  TermsOfService.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//


import UIKit
import UserNotifications
import WebKit

class TermsOfService: UIViewController {

    /*--- VIEWS ---*/
    @IBOutlet var webView: WKWebView!
    

    
    
    // ------------------------------------------------
    // HIDE STATUS BAR
    // ------------------------------------------------
    override var prefersStatusBarHidden : Bool {
            return true
    }
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        // Show tou.html
        let url = Bundle.main.url(forResource: "tou", withExtension: "html")
        let myRequest = URLRequest(url: url!)
        self.webView.load(myRequest)
    }


    
    // ------------------------------------------------
    // DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    }
