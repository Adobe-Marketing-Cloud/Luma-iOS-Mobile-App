//
//  ProductList.swift
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
import Apollo
import MagentoAPI


class ProductsList: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    
    /*--- VIEWS ---*/
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productsCollView: UICollectionView!
    
    
        
    /*--- VARIABLES ---*/
    var categoryId = 0
    var categoryName = ""
    var searchStr = ""
    var productsArray = [ProductsQuery.Data.Products.Item?]()
        
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        
        print("Category Id", categoryId)
        
        // Layout
        if categoryName != "" {
            titleLabel.text = "\(categoryName)"
            //productCAT = categoryName.lowercased()
        } else {titleLabel.text = "Products found" }

        // call query
        queryProducts()
    }

    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        // Adobe Experience Platform - Send XDM Event
        let stateName = "luma: content: ios: us: en: \(categoryName)"
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
    // QUERY PRODUCTS
    // ------------------------------------------------
    func queryProducts() {
        showHUD()
        let query = PFQuery(className: PRODUCTS_CLASS_NAME)
        if searchStr != "" {
            let keywords = searchStr.lowercased().components(separatedBy: " ")
            query.whereKey(PRODUCTS_KEYWORDS, containedIn: keywords)
        } else {
            query.whereKey(PRODUCTS_CATEGORY, equalTo: categoryName)
        }
        query.order(byDescending: "createdAt")
        query.fromLocalDatastore()
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                let categoryId: FilterEqualTypeInput = FilterEqualTypeInput(eq: .some(String(self.categoryId)))
                var filterByCategoryId = ProductAttributeFilterInput(category_id: .some(categoryId));
                Network.shared.apollo.fetch(query: ProductsQuery(filter: .some(filterByCategoryId))) { result in
                    switch result {
                    case .success(let response):
                        if let products = response.data?.products?.items {
                            print("Categories", products)
                            
                            self.productsArray = products
                            self.productsCollView.reloadData()
                            self.hideHUD()
                            
                        } else if let errors = response.errors {
                            print("Errors", errors)
                            print("Errors", errors)
                        }
                    case .failure(let error):
                        print("Test Error",error)
                    }
                }
                
                //self.productsArray = objects!
                //self.productsCollView.reloadData()
                //self.hideHUD()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    }
    
    
    
    
    // ------------------------------------------------
    // SHOW DATA IN COLLECTION VIEW
    // ------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        // Parse Obj
        //var pObj = PFObject(className: PRODUCTS_CLASS_NAME)
        var pObj = productsArray[indexPath.row]

        // Name
        cell.pNameLabel.text = pObj?.name
        
        // Price
        let fPrice = pObj?.price_range.minimum_price.regular_price.value as! Double
        //let currency = pObj?.price_range.minimum_price.regular_price.currency as! String
        //cell.pPriceLabel.text = "\(currency) \(fPrice)"
        cell.pPriceLabel.text = "\(fPrice)"
        // Image 1
        let pfProduct = PFObject(className:"Categories")
        let image = pObj?.image?.url ?? "https://images.unsplash.com/photo-1620646233562-f2a31ad24425?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHN0YXJzJTIwYmxhY2t8ZW58MHx8MHx8&w=1000&q=80"
    
        getParseImage(location: image, colName: PRODUCTS_IMAGE1, imageView: cell.pImage)

        // Featured
        //let isfeatured = pObj[PRODUCTS_IS_FEATURED] as! Bool
        //if isfeatured { cell.featuredBadge.isHidden = false
        //} else { cell.featuredBadge.isHidden = true }

        
    return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2 - 20, height: collectionView.frame.size.width/2 - 20)
    }
    
    
    
    // ------------------------------------------------
    // SELECT PRODUCT -> SHOW ITS INFO
    // ------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //var pObj = PFObject(className: PRODUCTS_CLASS_NAME)
        var pObj = productsArray[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductInfo") as! ProductInfo
        //vc.pObj = pObj
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
    
    
    // ------------------------------------------------
    // CART BUTTON
    // ------------------------------------------------
    @IBAction func cartButt(_ sender: AnyObject) {
        // currentUser IS LOGGED IN!
        if PFUser.current() != nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Cart") as! Cart
            present(vc, animated: true, completion: nil)
            
            // currentUser IN NOT LOGGED IN...
        } else {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(aVC, animated: true, completion: nil)
        }
    }

    
    
    

    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }

    
    
}// ./ end
