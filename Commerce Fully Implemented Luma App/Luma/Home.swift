//
//  Main.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import CoreLocation
import UserNotifications
import WebKit

import Alamofire
import SwiftyJSON

//Adobe AEP SDKs
import AEPUserProfile
import AEPAssurance
import AEPEdge
import AEPCore
import AEPEdgeIdentity
import AEPEdgeConsent
import Foundation
import Apollo
import MagentoAPI

class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    
    /*--- VIEWS ---*/
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var featuredScrollView: UIScrollView!
    @IBOutlet weak var webContent: WKWebView!
    let refreshControl = UIRefreshControl()
    
    
    
    /*--- VARIABLES ---*/
    var categoriesArray = [CategoriesQuery.Data.CategoryList.Child.Child]()
    var featuredArray = [PFObject]()
    var locationManager: CLLocationManager?


    static var cartArray = [PFObject]()
    
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        // Adobe Experience Platform - Send XDM Event
        //Prep Data
        let stateName = "luma: content: ios: us: en: home"
        var xdmData: [String: Any] = [
            "eventType": "web.webpagedetails.pageViews",
            "web": [
                "webPageDetails": [
                    "pageViews": [
                        "value": 1
                    ],
                    "name": "Home page"
                ]
            ]
        ]

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
        //Edge.sendEvent(experienceEvent: experienceEvent)
        Edge.sendEvent(experienceEvent: experienceEvent) { (handles: [EdgeEventHandle]) in
    
            // Handle the Edge Network response
        }
        
        // Adobe Experience Platform - Update Identity
        let emailLabel = "mobileuser@example.com"
        //let identityMap: IdentityMap = IdentityMap()
        //identityMap.add(item: IdentityItem(id: emailLabel), withNamespace: "Email")
        //Identity.updateIdentities(with: identityMap)
        
        let identityMap: IdentityMap = IdentityMap()
        identityMap.add(item: IdentityItem(id: emailLabel, primary: true), withNamespace: "Email")
        Identity.updateIdentities(with: identityMap)
    }
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        print("Start");
        
        let audienceId: FilterEqualTypeInput = FilterEqualTypeInput(eq: .some(String("0f0aa8b5-afc9-4328-bc8c-2a811af8649f")))
        var inputDynamicBlock = DynamicBlocksFilterInput(audience_id: .some(audienceId), type: GraphQLEnum(DynamicBlockTypeEnum.specified))
        Network.shared.apollo.fetch(query: DynamicBlocksQuery(input: GraphQLNullable(inputDynamicBlock))) { result in
            switch result {
            case .success(let response):
                if let banners = response.data?.dynamicBlocks.items {
                    print("Banners", banners)
                    
                    var bannersHtml = "";
                    
                    for banner in banners {
                        bannersHtml += banner?.content.html ??  ""
                    }
                    
                    self.webContent.loadHTMLString(bannersHtml, baseURL: nil)
                    
                } else if let errors = response.errors {
                    print("Errors", errors)
                }
            case .failure(let error):
                print("Test Error",error)
            }
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()


        // Adobe Experience Platform - Consent - Get
        Consent.getConsents{ consents, error in
            guard error == nil, let consents = consents else { return }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: consents, options: .prettyPrinted) else { return }
            guard let jsonStr = String(data: jsonData, encoding: .utf8) else { return }
            print("Consent getConsents: ",jsonStr)
        }
        let defaults = UserDefaults.standard
        let consentKey = "askForConsentYet"
        let hidePopUp = defaults.bool(forKey: consentKey)
        
        // Adobe Experience Platform - Consent - Update
        //Check if user has been asked for consent
        if(hidePopUp == false){
            //Consent Alert
            let alert = UIAlertController(title: "Allow Data Collection?", message: "Selecting Yes will begin data collection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                //Update Consent -> "yes"
                let collectConsent = ["collect": ["val": "y"]]
                let currentConsents = ["consents": collectConsent]
                Consent.update(with: currentConsents)
                defaults.set(true, forKey: consentKey)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                //Update Consent -> "no"
                let collectConsent = ["collect": ["val": "n"]]
                let currentConsents = ["consents": collectConsent]
                Consent.update(with: currentConsents)
                defaults.set(true, forKey: consentKey)
            }))
            self.present(alert, animated: true)
        }
        
        
        // Refresh Control
        refreshControl.tintColor = MAIN_COLOR
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        categoryTableView.addSubview(refreshControl)
        

        // Load categories
        queryCategories()
        
        // Load featured products
        queryFeaturedProducts()
        
        // Layout
        searchTxt.frame.size.height = 54
        

        let query = PFQuery(className: PRODUCTS_CLASS_NAME)
        query.whereKey(PRODUCTS_IS_FEATURED, equalTo: true)
        query.fromLocalDatastore()
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    print(object.objectId as Any)
                }
            }
        }

    }

    

    // ------------------------------------------------
    // QUERY CATEGORIES
    // ------------------------------------------------
    func queryCategories() {
        showHUD()
        let query = PFQuery(className: CATEGORIES_CLASS_NAME)
        query.fromLocalDatastore()
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.hideHUD()
                for object in objects! {
                    print(object.objectId as Any)

                }
                
                Network.shared.apollo.fetch(query: CategoriesQuery()) { result in
                    switch result {
                    case .success(let response):
                        if let categories = response.data?.categoryList {
                            var flatCategories: [CategoriesQuery.Data.CategoryList.Child.Child] = [];
                            for child in categories[0]?.children ?? [] {
                                if (child != nil) {
                                    let children = child?.children ?? []
                                    for child in children {
                                        flatCategories.append(child!)
                                    }
                                }
                            }
                            self.categoriesArray = flatCategories;
                            self.categoryTableView.reloadData()
                            self.hideHUD()
                        } else if let errors = response.errors {
                            print("Errors", errors)
                            print("Errors", errors)
                        }
                    case .failure(let error):
                        print("Test Error",error)
                    }
                }
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
    
    
    
    // ------------------------------------------------
    // QUERY FEATURED PRODUCTS
    // ------------------------------------------------
    func queryFeaturedProducts() {
        let query = PFQuery(className: PRODUCTS_CLASS_NAME)
        query.whereKey(PRODUCTS_IS_FEATURED, equalTo: true)
        query.fromLocalDatastore()
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.featuredArray = objects!
                self.setFeaturedButtons()
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
    
    
    
    // ------------------------------------------------
    // SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell

        // Parse Obj
        var cObj = categoriesArray[indexPath.row]
        
        // Name
        cell.catName.text = cObj.name
        
        let pfCategory = PFObject(className:"Categories")
        let image = cObj.image ?? "https://images.unsplash.com/photo-1620646233562-f2a31ad24425?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHN0YXJzJTIwYmxhY2t8ZW58MHx8MHx8&w=1000&q=80"
        // Image
        getParseImage(location: image, colName: CATEGORIES_IMAGE, imageView: cell.catImage)
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    // ------------------------------------------------
    // SELECT A CATEGORY
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Parse Obj
        //var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        var cObj = categoriesArray[indexPath.row]
        
        // print
        productCategory = cObj.name!
        print ("Cateogry is --> \(productCategory)")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductsList") as! ProductsList
        vc.categoryId = cObj.id!
        vc.categoryName = cObj.name!
        navigationController?.pushViewController(vc, animated: true)
    }

    
    // ------------------------------------------------
    // TEXTFIELD DELEGATES FOR SEARCH
    // ------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ProductsList") as! ProductsList
            vc.searchStr = textField.text!
            navigationController?.pushViewController(vc, animated: true)
        }
    return true
    }
    
    
    // ------------------------------------------------
    // DISMISS KEYBOARD ON SCROLL DOWN
    // ------------------------------------------------
    var lastContentOffset: CGFloat = 0
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            searchTxt.resignFirstResponder()
        }
    }
    
    
    
    
    
    // ------------------------------------------------
    // SET FEATURED BUTTONS
    // ------------------------------------------------
    func setFeaturedButtons() {
        var X:CGFloat = 0
        let Y:CGFloat = 0
        let W:CGFloat = 200
        let H:CGFloat = 120
        let G:CGFloat = 4
        
        // Counter
        var counter = 0
        
        // Loop to create views -----------------
        for i in 0..<featuredArray.count {
            counter = i
            
            // Parse Obj
            var fObj = PFObject(className: PRODUCTS_CLASS_NAME)
            fObj = featuredArray[i]
            
            // Button
            let aButt = UIButton(type: .custom)
            aButt.frame = CGRect(x: X, y: Y, width: W, height: H)
            aButt.tag = i
            getParseImage(object: fObj, colName: PRODUCTS_IMAGE1, button: aButt)
            aButt.imageView?.contentMode = .scaleAspectFill
            aButt.clipsToBounds = true
            aButt.layer.cornerRadius = 5
            aButt.addTarget(self, action: #selector(productSelected(_:)), for: .touchUpInside)
            
            // Label
            let aLabel = UILabel(frame: CGRect(x: X+8, y: 88, width: aButt.frame.size.width-24, height: 28))
            aLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
            aLabel.textColor = UIColor.white
            aLabel.shadowColor = UIColor.black
            aLabel.shadowOffset = CGSize(width: 1, height: 1)
            aLabel.adjustsFontSizeToFitWidth = true
            aLabel.numberOfLines = 2
            let finalPrice = fObj[PRODUCTS_FINAL_PRICE] as! Double
            aLabel.text = "\(fObj[PRODUCTS_NAME]!) | \(fObj[PRODUCTS_CURRENCY]!) \(finalPrice)"

            
            // Add Buttons based on X
            X += W + G
            featuredScrollView.addSubview(aButt)
            featuredScrollView.addSubview(aLabel)
        } // end for loop --------------------------
        
        // Place Buttons into the ScrollView
        featuredScrollView.contentSize = CGSize(width: W * CGFloat(counter+2), height: H)
    }
    
    
    
    // ------------------------------------------------
    // FEATURED PRODUCT SELECTED
    // ------------------------------------------------
    @objc func productSelected(_ sender: UIButton) {
        // Parse Obj
        var fObj = PFObject(className: PRODUCTS_CLASS_NAME)
        fObj = featuredArray[sender.tag]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductInfo") as! ProductInfo
        vc.pObj = fObj
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    // ------------------------------------------------
    // CART BUTTON
    // ------------------------------------------------
    @IBAction func cartButt(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Cart") as! Cart
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
    // ------------------------------------------------
    // REFRESH DATA
    // ------------------------------------------------
    @objc func refreshData () {
        // Recall query
        queryCategories()
        
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }

}// ./ end
