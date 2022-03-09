//
//  Wishlist.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import UserNotifications

import Alamofire
import SwiftyJSON

//Adobe AEP SDKs
import AEPCore
import AEPEdge

class Wishlist: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    
    /*--- VIEWS ---*/
    @IBOutlet weak var productsCollView: UICollectionView!

        
        
    /*--- VARIABLES ---*/
    var productsArray = [PFObject]()
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        queryWishlist()
        
        // Adobe Experience Platform - Send XDM Event
        //Prep Data
        let stateName = "luma: content: ios: us: en: wishlist"
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
    }

    
    // ------------------------------------------------
    // QUERY WISHLIST
    // ------------------------------------------------
    func queryWishlist() {
//        showHUD()
//
//        let query = PFQuery(className: PRODUCTS_CLASS_NAME)
//        query.whereKey(PRODUCTS_WISHLISTED_BY, containedIn: [currentUser.objectId!])
//        query.fromLocalDatastore()
//        query.findObjectsInBackground { (objects, error) in
//            if error == nil {
//                print ("found wish list items...")
//                self.hideHUD()
//                self.productsArray = objects!
//                self.productsCollView.reloadData()
//            // error
//            } else {
//                self.hideHUD()
//                self.simpleAlert("\(error!.localizedDescription)")
//        }}
        
    }
    
    
    
    // ------------------------------------------------
    // SHOW DATA IN COLLECTION VIEW
    // ------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return productsArray.count
        
        return arrWishlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        print ("I am here in a Collection View")
        // Parse Obj
        //var pObj = PFObject(className: PRODUCTS_CLASS_NAME)
        
        if arrWishlist.count != 0{
            
            let dictObject :NSDictionary = arrWishlist.object(at: indexPath.row) as! NSDictionary
             print("dictObject---->>>\(dictObject)")
            if let dictEntity = dictObject.object(forKey: "entity") as? NSDictionary {
                
                print("dictEntity---->>>\(dictEntity)")
                
              if let arr = dictEntity.object(forKey: "productListItems") as? NSArray {
            //if  let dictProduct :NSDictionary = dictObject.object(forKey: "") as? NSDictionary{
                print("arr---->>>\(arr)")
                if arr.count != 0{
                    
                    
                     let dictDetail :NSDictionary = arr.object(at: 0) as! NSDictionary
                    
                     print("dictDetail---->>\(dictDetail)")
                    
                    // Name
                  
                      cell.pNameLabel.text = "$ \(string(dictDetail, "name"))"
                  
                        cell.pPriceLabel.text = "$ \(number(dictDetail, "priceTotal"))"
              
                }
             }
            }
            
            // Tags
            cell.deleteButton.tag = indexPath.row
            
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2 - 20, height: collectionView.frame.size.width/2 - 20)
    }
    
    
    
    // ------------------------------------------------
    // SELECT PRODUCT -> SHOW ITS INFO
    // ------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Parse Obj
        var pObj = PFObject(className: PRODUCTS_CLASS_NAME)
        pObj = productsArray[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductInfo") as! ProductInfo
        vc.pObj = pObj
        navigationController?.pushViewController(vc, animated: true)
    }
 
    // ------------------------------------------------
    // DELETE WISHLISTED PRODUCT BUTTON
    // ------------------------------------------------
    @IBAction func deleteButt(_ sender: UIButton) {

        // Adobe Experience Platform - Send XDM Event
        //Prep Data
        let actionName = "Remove from Wishlist"
        let sku = "test123"
        let productName = "Product Name"
        let price = 19.99
        //Commerce
        var xdmData: [String: Any] = [
          "commerce": [
            "saveForLaters": [
              "value": 1
            ]
          ],
          "productListItems": [
            [
              "name": productName,
              "priceTotal": price,
              "sku": sku
            ]
          ]
        ]

        //Action
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
    // CART BUTTON
    // ------------------------------------------------
    @IBAction func cartButt(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Cart") as! Cart
        present(vc, animated: true, completion: nil)
    }

    ///
    // ------------------------------------------------
    // MARK:- showEEInfo
    // ------------------------------------------------
    
    var arrWishlist = NSMutableArray()
    
    
    func showEEInfo() {
        
    }
    
    
    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }

        

        
}// ./ end

