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

import Alamofire
import SwiftyJSON


class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    
    /*--- VIEWS ---*/
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var featuredScrollView: UIScrollView!
    let refreshControl = UIRefreshControl()
    
    
    
    /*--- VARIABLES ---*/
    var categoriesArray = [PFObject]()
    var featuredArray = [PFObject]()
    var locationManager: CLLocationManager?


    static var cartArray = [PFObject]()
    
    
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
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        
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
                print(error.localizedDescription)
            } else if let objects = objects {
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
                self.categoriesArray = objects!
                self.categoryTableView.reloadData()
            // error
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
        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        cObj = categoriesArray[indexPath.row]
        
        // Name
        cell.catName.text = "\(cObj[CATEGORIES_CATEGORY]!)"
        
        // Image
        getParseImage(object: cObj, colName: CATEGORIES_IMAGE, imageView: cell.catImage)
        
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
        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        cObj = categoriesArray[indexPath.row]
        
        // print
        productCategory = cObj[CATEGORIES_CATEGORY]! as! String
        print ("Cateogry is --> \(productCategory)")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductsList") as! ProductsList
        vc.categoryName = "\(cObj[CATEGORIES_CATEGORY]!)"
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
