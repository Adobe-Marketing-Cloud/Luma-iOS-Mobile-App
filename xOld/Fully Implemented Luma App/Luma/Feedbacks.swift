//
//  Feedbacks.swift
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
import AEPCore
import AEPEdge

class Feedbacks: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /*--- VIEWS  ---*/
    @IBOutlet weak var feedbacksTableView: UITableView!
    
    

    /*--- VARIABLES ---*/
    var prodObj = PFObject(className: PRODUCTS_CLASS_NAME)
    var feedbacksArray = [PFObject]()
    
    
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()

        // Call query
        queryReviews()
    }

    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {

        // Adobe Experience Platform - Send XDM Event
        let stateName = "luma: content: ios: us: en: feedbacks"
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
    // QUERY REVIEWS
    // ------------------------------------------------
    func queryReviews() {
        //not currently implemented
    }
    

    
    // TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacksArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackCell
        
        // Parse Obj
        var fObj = PFObject(className: FEEDBACKS_CLASS_NAME)
        fObj = feedbacksArray[indexPath.row]
        
        // User Pointer
        let userPointer = fObj[FEEDBACKS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                // Avatar
                self.getParseImage(object: userPointer, colName: USER_AVATAR, imageView: cell.avatarImg)
                
                // Name
                //cell.nameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                cell.nameLabel.text = "\(userPointer[USER_USERNAME]!)"
                
                // Stars
                let stars = fObj[FEEDBACKS_STARS] as! Int
                cell.starImg.image = UIImage(named:"\(stars)star")
                
                // Review
                cell.feedbackTxt.text = "\(fObj[FEEDBACKS_FEEDBACK]!)"
                
                
            // error
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }})// ./ userPointer
        

    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    
    
    
    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
