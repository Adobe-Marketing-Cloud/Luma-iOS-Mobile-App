//
//  BrandSelection.swift
//  La Boutique Experience Platform
//
//  Created by Wouter Van Geluwe on 27/05/2019.
//  Copyright © 2019 xscoder. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import Foundation

import Alamofire
import SwiftyJSON

class StoreSelection: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    /*--- VIEWS ---*/
    @IBOutlet weak var brandsPickerView: UIPickerView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var backButt: UIButton!
    @IBOutlet weak var saveBrandButt: UIButton!
    @IBOutlet weak var ldapLabel: UILabel!
    @IBOutlet weak var brandLogoImage: UIImageView!
    
    /*--- VARIABLES ---*/
    var brandArray = [PFObject]()
    var storeArray = [PFObject]()
    
    //var brandSelected = false
    var storeSelected = false
    
    //var selectedBrand = ""
    //var selectedBrandId = ""
    var selectedStore = ""
    var selectedStoreId = ""
    var selectedBrandImage : UIImage?
    
    // ------------------------------------------------
    // MARK: - VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        //loadBrandImage()
        //var ldapId = UserDefaults.standard.string(forKey: "ldapName") ?? "default"
        let ldapId = "default"
        //APP_NAME = UserDefaults.standard.string(forKey: "brandName") ?? "Luma"
        //let APP_NAME = "Luma"
        self.ldapLabel.text = "Your selected Region: " + ldapId
        
        // Call query
        queryStores()
        
    }
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        loadBrandImage()
        
        // Call queries
        queryStores()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.brandsPickerView.delegate = self
            self.brandsPickerView.dataSource = self
            self.brandsPickerView.selectRow(1, inComponent:0, animated:true)
            self.pickerView(self.brandsPickerView, didSelectRow: 1, inComponent: 0)
        }
        
        super.viewDidLoad()
        
        // Refresh Control
        refreshControl.tintColor = MAIN_COLOR
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        
    }
    
    // ------------------------------------------------
    // MARK: -  QUERY BRANDS
    // ------------------------------------------------
    func queryStores() {
        //var ldapList = [String]()
        //var ldapId = UserDefaults.standard.string(forKey: "ldapName") ?? "all"
        //ldapList.append("all")
        //ldapList.append(ldapId)
        let query = PFQuery(className: STORES_CLASS_NAME)
        //query.whereKey(BRAND_LDAP, containedIn: ldapList)
        //query.whereKey(BRAND_ACTIVE, equalTo: "Y")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.brandArray = objects!
                print("Query Stores: BrandArray is -> \(self.brandArray)")
                print("Query Stores Count: BrandArray is -> \(self.brandArray.count)")
                // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    // ------------------------------------------------
    // MARK: - REFRESH DATA
    // ------------------------------------------------
    @objc func refreshData () {
        // Recall query
        queryStores()
        
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //print("BrandCount is -> \(self.brandArray.count)")
    return self.brandArray.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var cObj = PFObject(className: STORES_CLASS_NAME)
        cObj = brandArray[row]
        
        let cellContent = "\(cObj[STORES_STORENAME]!)"
        
        return cellContent
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Mathieu - bug fixing in case no brands are defined in the backend
        if brandArray.isEmpty == false {
            
            if brandArray.capacity > 1  {
            // Mathieu - bug fixing causing a crash
            //print ("at least 2 elements")
            selectedStore = brandArray[row][STORES_STORENAME] as! String
            selectedStoreId = brandArray[row][STORES_STOREID] as! String
        
            /*
            if let imageFile : PFFile = brandArray[row][BRAND_BRANDLOGO] as? PFFile {
                imageFile.getDataInBackground(block: { (data, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            // Async main thread
                        
                            let image = UIImage(data: data!)
                            self.selectedBrandImage = image
                            print("Selected Brand Logo is -> \(String(describing: self.selectedBrandImage))")
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
        
            //print("Selected Brand is -> \(selectedBrand)")
            //print("Selected Brand Object ID is -> \(selectedBrandObjectId)")
            //print("Selected Brand Logo is -> \(String(describing: selectedBrandImage))")}
                }
             */
            } else
            {
                // Mathieu - bug fixing causing a crash
                //print ("1 element")
                selectedStore = brandArray[0][STORES_STORENAME] as! String
                selectedStoreId = brandArray[0][STORES_STOREID] as! String
                
                /*
                if let imageFile : PFFile = brandArray[0][BRAND_BRANDLOGO] as? PFFile {
                    imageFile.getDataInBackground(block: { (data, error) in
                        if error == nil {
                            DispatchQueue.main.async {
                                // Async main thread
                                
                                let image = UIImage(data: data!)
                                self.selectedBrandImage = image
                                print("Selected Brand Logo is -> \(String(describing: self.selectedBrandImage))")
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                    
                    //print("Selected Brand is -> \(selectedBrand)")
                    //print("Selected Brand Object ID is -> \(selectedBrandObjectId)")
                    //print("Selected Brand Logo is -> \(String(describing: selectedBrandImage))")}
                }
                */
            }
        }}
    
    // ------------------------------------------------
    // UPDATE SELECTED STORE
    // ------------------------------------------------
    @IBAction func saveBrandButt(_ sender: Any) {
        showHUD()
        print("Selected Store is -> \(selectedStore)")
        print("Selected Store ID is -> \(selectedStoreId)")

        
        //print("Selected Brand Logo is -> \(String(describing: selectedBrandImage))")
        
        //UserDefaults.standard.set(selectedBrand, forKey: "brandName")
        //UserDefaults.standard.set(selectedBrandId, forKey: "brandId")
        
        //let imageName = "brandLogo" // your image name here
        //let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        //let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        //let newImage: UIImage = selectedBrandImage ?? UIImage(named: "platform")!
        //print("Save - Selected Brand Logo is -> \(String(describing: newImage))")
        //try? newImage.pngData()?.write(to: imageUrl)
        
        //dismissKeyboard()
        hideHUD()
        backButt(sender)
    }
    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func loadBrandImage() {
        
        let imageName = "brandLogo" // your image name here
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        guard FileManager.default.fileExists(atPath: imagePath),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData) else {
                return // No image found!
        }
        
        self.brandLogoImage.contentMode = .scaleAspectFit
        self.brandLogoImage.image = image
    }
}// ./ end
