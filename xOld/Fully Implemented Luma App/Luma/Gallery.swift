//
//  Gallery.swift
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

class Gallery: UIViewController, UIScrollViewDelegate {

    /*--- VIEWS ---*/
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pNameLabel: UILabel!
    
    
    
    /*--- VARIABLES ---*/
    var pObj = PFObject(className: PRODUCTS_CLASS_NAME)
    var photosArray = [UIImage]()
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        // Adobe Experience Platform - Send XDM Event
        let stateName = "Product Gallery - \(pNameLabel.text ?? "")"
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

        // Product Name
        pNameLabel.text = "\(pObj[PRODUCTS_NAME]!)"

        // Photos
        let imageFile = pObj[PRODUCTS_IMAGE1] as? PFFile
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.photosArray.append(UIImage(data: imageData)!)
                self.setupPhotosInScrollView()
                print("PHOTO 1")
        }}})

        DispatchQueue.main.async {

            if self.pObj[PRODUCTS_IMAGE2] != nil {
                self.pageControl.numberOfPages = 2
                let imageFile = self.pObj[PRODUCTS_IMAGE2] as? PFFile
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        self.photosArray.append(UIImage(data: imageData)!)
                        self.setupPhotosInScrollView()
                        print("PHOTO 2")
                }}})
            }
            if self.pObj[PRODUCTS_IMAGE3] != nil {
                self.pageControl.numberOfPages = 3
                let imageFile = self.pObj[PRODUCTS_IMAGE3] as? PFFile
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        self.photosArray.append(UIImage(data: imageData)!)
                        self.setupPhotosInScrollView()
                        print("PHOTO 3")
                }}})
            }
            if self.pObj[PRODUCTS_IMAGE4] != nil {
                self.pageControl.numberOfPages = 4
                let imageFile = self.pObj[PRODUCTS_IMAGE4] as? PFFile
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        self.photosArray.append(UIImage(data: imageData)!)
                        self.setupPhotosInScrollView()
                        print("PHOTO 4")
                }}})
            }
            
        }// ./ Dispatch async
    }

    // ------------------------------------------------
    // SETUP PHOTOS IN SCROLLVIEW
    // ------------------------------------------------
    @objc func setupPhotosInScrollView() {
        var X:CGFloat = 0
        let Y:CGFloat = 0
        let W:CGFloat = view.frame.size.width
        let H:CGFloat = view.frame.size.height
        let G:CGFloat = 0
        var counter = 0
        
        // Loop to create ImageViews
        for i in 0..<photosArray.count {
            counter = i
            
            // Create a ImageView
            let aImg = UIImageView(frame: CGRect(x: X, y: Y, width: W, height: H))
            aImg.tag = i
            aImg.contentMode = .scaleAspectFit
            aImg.image = photosArray[i]
            
            // Add ImageViews based on X
            X += W + G
            containerScrollView.addSubview(aImg)
 
        } // ./ FOR loop
        
        // Place Buttons into a ScrollView
        containerScrollView.contentSize = CGSize(width: W * CGFloat(counter+2), height: H)
    }
    
    
    // ------------------------------------------------
    // CHANGE PAGE CONTROL PAGES ON SCROLL
    // ------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = containerScrollView.frame.size.width
        let page = Int(floor((containerScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
        pageControl.currentPage = page
    }

    
    
    
    
    // ------------------------------------------------
    // DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}// ./ end
