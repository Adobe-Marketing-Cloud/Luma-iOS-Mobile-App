//
//  Orders.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import UserNotifications

class Orders: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /* Views */
    @IBOutlet weak var ordersTableView: UITableView!
    let refreshControl = UIRefreshControl()

    
    
    /* Variables */
    var ordersArray = [PFObject]()
   
    var productList = ""
    var cartCount = 1
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()

        // Refresh Control
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
        ordersTableView.addSubview(refreshControl)


        // Call query
        queryOrders()
    }


    
    
    // ------------------------------------------------
    // QUERY ORDERS
    // ------------------------------------------------
    func queryOrders() {
        //Not currently implemented
    }
    
    
    
    // ------------------------------------------------
    // SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        
        // Parse Obj
        var oObj = PFObject(className: ORDERS_CLASS_NAME)
        oObj = ordersArray[indexPath.row]
        var totaltemp = 0.0
        
        
        // productPointer
        let prodPointer = oObj[ORDERS_PRODUCT_POINTER] as! PFObject
        prodPointer.fetchIfNeededInBackground { (object, error) in
            
            // Product name
            cell.pNameLabel.text = "\(prodPointer[PRODUCTS_NAME]!) | \(oObj[ORDERS_PRODUCT_SIZE]!)"
            
            
            // Qty
            cell.pQtyLabel.text = "Qty: \(oObj[ORDERS_PRODUCT_QTY]!)"
            let price = prodPointer[PRODUCTS_FINAL_PRICE] as! Double

            totaltemp = price * (oObj[ORDERS_PRODUCT_QTY]! as! Double)
            self.productList = self.productList + ";\((prodPointer[PRODUCTS_NAME]! as! String).lowercased());\(oObj[ORDERS_PRODUCT_QTY]!);\(totaltemp)"
            
            // Date
            let date = oObj.createdAt!
            let df = DateFormatter()
            df.dateFormat = "MMM dd yyyy | hh:mm a"
            cell.pDateLabel.text = "Ordered on " + df.string(from: date)
                    
            // Image 1
            self.getParseImage(object: prodPointer, colName: PRODUCTS_IMAGE1, imageView: cell.pImage)
            
            // Delivery date
            cell.pDeliveryByLabel.text = "\(oObj[ORDERS_DELIVERY_DATE]!)"
            
            if self.cartCount == self.ordersArray.count  {
                
            } else {
                self.cartCount += 1
                self.productList = self.productList + ","
                
            }
        }// ./ prodPointer
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
    
    
    
    
    // ------------------------------------------------
    // SELECT A PRODUCT -> SEE ITS DETAILS
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Parse Obj
        var oObj = PFObject(className: ORDERS_CLASS_NAME)
        oObj = ordersArray[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "OrderDetails") as! OrderDetails
        vc.orderObj = oObj
        navigationController?.pushViewController(vc, animated: true)
    }

    
    
    
    // ------------------------------------------------
    // REFRESH DATA
    // ------------------------------------------------
    @objc func refreshTB () {
        // Recall query
        queryOrders()
        
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }



    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
}// ./ end
