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

//Adobe AEP SDKs
import AEPEdge
import AEPCore
import AEPEdgeIdentity
import AEPIdentity

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

        // Adobe Experience Platform - Handle Web View
        AEPIdentity.Identity.appendTo(url: url) {returnedURL, error in
            let myRequest = URLRequest(url: returnedURL!)
            self.webView.load(myRequest)
        }
    
        
        // Adobe Experience Platform - Send XDM Event
        let stateName = "luma: content: ios: us: en: terms of service"
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
