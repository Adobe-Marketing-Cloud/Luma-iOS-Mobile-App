//
//  LeaveFeedback.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse

//Adobe AEP SDKs
import AEPCore
import AEPEdge


class LeaveFeedback: UIViewController {

    /*--- VIEWS  ---*/
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var pNameLabel: UILabel!
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var feedbackTxt: UITextView!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    
    /*--- VARIABLES ---*/
    var orderObj = PFObject(className: ORDERS_CLASS_NAME)
    var starNr = 0
    
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout
        pImage.layer.cornerRadius = 5
        feedbackTxt.layer.cornerRadius = 8
        sendFeedbackButton.layer.cornerRadius = 8
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                                 height: 800)
        
        // Initialize Star buttons
        for butt in starButtons {
            butt.setBackgroundImage(UIImage(named: "empty_star"), for: .normal)
            butt.addTarget(self, action: #selector(starButtTapped(_:)), for: .touchUpInside)
        }
        
        
        starNr = 0
        
        // Get product pointer
        getProductPointer()
    }
    
    
    
    
    // ------------------------------------------------
    // GET PRODUCT POINTER
    // ------------------------------------------------
    func getProductPointer() {
        //not currently implmented
    }
    
    
    
    
    // ------------------------------------------------
    // STAR BUTTON
    // ------------------------------------------------
    @objc func starButtTapped (_ sender: UIButton) {
        let button = sender as UIButton
        
        for i in 0..<starButtons.count {
            starButtons[i].setBackgroundImage(UIImage(named: "empty_star"), for: .normal)
        }
        
        starNr = button.tag + 1
        print("STARS: \(starNr)")
        for star in 0..<starNr {
            starButtons[star].setBackgroundImage(UIImage(named: "full_star"), for: .normal)
        }
    }
    
    
    
    
    
    
    // ------------------------------------------------
    // SEND FEEDBACK BUTTON
    // ------------------------------------------------
    @IBAction func sendFeedbackButt(_ sender: Any) {

        // Adobe Experience Platform - Send XDM Event
        let actionName = "Leave Feedback"
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
        
    }
    
    
    
    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    

}// ./ end
