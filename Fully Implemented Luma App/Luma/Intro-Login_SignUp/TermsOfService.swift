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
        if var urlString = url?.absoluteString {
            // Adobe Experience Platform - Handle Web View
            AEPEdgeIdentity.Identity.getUrlVariables {(urlVariables, error) in
                if let error = error {
                    self.simpleAlert("\(error.localizedDescription)")
                    return;
                }
                
                
                if let urlVariables: String = urlVariables {
                    urlString.append("?" + urlVariables)
                }
                
                DispatchQueue.main.async {
                    self.webView.load(URLRequest(url: URL(string: urlString)!))
                }
                print("Successfully retrieved urlVariables for WebView, final URL: \(urlString)")
            }
        } else {
            self.simpleAlert("Failed to create URL for webView")
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
