//
//  Cart.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import UserNotifications

class Cart: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    /*
    IMPORTANT: BEFORE SUBMITTING THE APP TO THE APP STORE:
        1. UNCOMMENT PayPalEnvironmentProduction
        2. REMOVE PayPalEnvironmentNoNetwork:
    */
    //var environment:String = PayPalEnvironmentSandbox /* PayPalEnvironmentProduction */  {
        
    //willSet(newEnvironment) {
    //    if (newEnvironment != environment) { PayPalMobile.preconnect(withEnvironment: newEnvironment) }
    //}}
    //var payPalConfig = PayPalConfiguration()

    
    
    /*--- VIEWS ---*/
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var shippingAddressLabel: UILabel!
    @IBOutlet weak var orderlabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var orderCompleteView: UIView!
    @IBOutlet weak var backToShopButton: UIButton!
    
    
    
    
    /*--- VARIABLES ---*/
    //var cartArray = [PFObject]()
    var totalAmountArray = [Double]()
    var productsOrdered = [String]()
    var totalAmountStr = ""
    var proofOfPayment = ""
    var isCashOnDelivery = false
    
    
    var productListItems = [[String:Any]]()
    //var productListOrder = ""
    var cartCount = 1
    var cartCountOrder = 0
    
    let cartArray = ProductBridge.getCartArray()
    
    // ------------------------------------------------
    // VIEW WILL APPEAR
    // ------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        orderCompleteView.frame.origin.y = view.frame.size.height
    }
    
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
//        // currentUser IS NOT LOGGED IN...
//        if PFUser.current() == nil {
//            let alert = UIAlertController(title: APP_NAME,
//                message: "You must be logged in to check your Cart!",
//                preferredStyle: .alert)
//
//            // Sign in
//            let signin = UIAlertAction(title: "Sign In", style: .default, handler: { (action) -> Void in
//                let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
//                self.present(aVC, animated: true, completion: nil)
//            })
//            alert.addAction(signin)
//
//            // Cancel
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
//            alert.addAction(cancel)
//
//            present(alert, animated: true, completion: nil)
//        }
    }
    
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()

        
        
        // Layout
        checkoutButton.layer.cornerRadius = 8
        backToShopButton.layer.cornerRadius = 8
        
        
        // Call query
        queryCart()
    }


    
    
    // ------------------------------------------------
    // QUERY CART
    // ------------------------------------------------
    func queryCart() {
        //showHUD()
        totalAmountArray = [Double]()
        //let currentUser = PFUser.current()!
        // Some Product in in the Cart!

        
        if cartArray.count != 0 {
            self.cartTableView.reloadData()
            
            // Get Total amount
            self.getTotalAmount()
                
            // Reset Checkout button
            self.checkoutButton.isEnabled = true
            self.checkoutButton.setTitle("Checkout", for: .normal)
            
        // NO products in the Cart...
        } else {
            self.totalAmountLabel.text = "\(CURRENCY_CODE) 0"
            self.checkoutButton.setTitle("Cart is empty", for: .normal)
            self.checkoutButton.isEnabled = false
        }
    }

    
    
    
    
    // ------------------------------------------------
    // SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("cartArray.count -> \(cartArray.count)")
        // cartCount = cartArray.count
        return cartArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        
        // Parse Obj
        //var cartObj = PFObject(className: CART_CLASS_NAME)
        let prodPointer = cartArray[indexPath.row]
        
//        // prodPointer
//        let prodPointer = cartObj[CART_PRODUCT_POINTER] as! PFObject
//        prodPointer.fetchIfNeededInBackground { (object, error) in
        
            // Name
            cell.pNameLabel.text = "\(prodPointer[PRODUCTS_NAME]!)"
            
            
            // Price
            let currency = "\(prodPointer[PRODUCTS_CURRENCY]!)"
            let price = prodPointer[PRODUCTS_FINAL_PRICE] as! Double
            cell.pPriceLabel.text = "\(currency) \(price)"
            
            // Quantity
            //cell.qtyLabel.text = "\(cartObj[CART_PRODUCT_QTY]!)"
            
            // Image 1
            self.getParseImage(object: prodPointer, colName: PRODUCTS_IMAGE1, imageView: cell.pImage)
            
            
            
            // Tags
            cell.removeProductButton.tag = indexPath.row
            cell.minusButton.tag = indexPath.row
            cell.plusButton.tag = indexPath.row

        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    
    
    
    
    // ------------------------------------------------
    // REMOVE PRODUCT BUTTON
    // ------------------------------------------------
    @IBAction func removeProductButt(_ sender: UIButton) {
//        showHUD()
//        let indexP = IndexPath(row: sender.tag, section: 0)
//        
//        var cartObj = PFObject(className: CART_CLASS_NAME)
//        cartObj = cartArray[sender.tag]
//        cartObj.deleteInBackground {(success, error) -> Void in
//            if error == nil {
//                self.hideHUD()
//                self.cartArray.remove(at: indexP.row)
//                self.cartTableView.deleteRows(at: [indexP], with: .fade)
//
//                // Recall query
//                self.queryCart()
//
//            // error
//            } else {
//                self.hideHUD()
//                self.simpleAlert("\(error!.localizedDescription)")
//        }}
    }
    
    
    
    
    
    
    

    
    
    

    
    // ------------------------------------------------
    // CHECKOUT BUTTON
    // ------------------------------------------------
    @IBAction func checkoutButt(_ sender:AnyObject) {
            // Fire alert
            let alert = UIAlertController(title: APP_NAME,
                message: "How do you wish to continue?",
                preferredStyle: .alert)

            // Credit Card
            let pay = UIAlertAction(title: "Credit Card", style: .default, handler: { (action) -> Void in
                self.proofOfPayment = "Credit Card"
                self.isCashOnDelivery = true
                self.processOrder()
            })
            alert.addAction(pay)

            // Cash on delivery
            let cash = UIAlertAction(title: "Cash on Delivery", style: .default, handler: { (action) -> Void in
                self.proofOfPayment = "Cash on delivery"
                self.isCashOnDelivery = true
                self.processOrder()
            })
            alert.addAction(cash)


            // Cancel
            let cancel = UIAlertAction(title: "Back to Cart", style: .destructive, handler: { (action) -> Void in })
            alert.addAction(cancel)

            present(alert, animated: true, completion: nil)
    }

    
    // ------------------------------------------------
    // PROCESS ORDER
    // ------------------------------------------------
    func processOrder() {
        // Show Order Complete View
        self.orderCompleteView.frame.origin.y = 0
        
        showHUD()
        var orderTotal = 0.00
        // Loop to create Orders
        for i in 0..<self.cartArray.count {
            let currentProduct = self.cartArray[i]
            let price = currentProduct["finalPrice"] as! Double
            let sku = currentProduct["objectId"]
            let units = 1.00
            let category = currentProduct["category"]
            let subCategory = currentProduct["subCategory"]
            orderTotal += (price*units)
            
        }
        
        var currency = "USD"
        
        
        hideHUD()
        self.simpleAlert("Order Placed!")
        
    }
    
    
    
    // ------------------------------------------------
    // GET TOTAL AMOUNT
    // ------------------------------------------------
    func getTotalAmount() {
        var orderTotal = 0.00
        // Loop to create Orders
        for i in 0..<self.cartArray.count {
            let currentProduct = self.cartArray[i]
            let price = currentProduct["finalPrice"] as! Double
            let units = 1.00
            orderTotal += (price*units)
        }
        let formattedFinalTotal = Double(round(1000 * orderTotal) / 1000)
        self.totalAmountLabel.text = "\(CURRENCY_CODE) \(formattedFinalTotal)"
        self.totalAmountStr = "\(formattedFinalTotal)"
    }
    
    
    
    // ------------------------------------------------
    // MINUS BUTTON
    // ------------------------------------------------
    @IBAction func minusButt(_ sender: UIButton) {
        //Not currently implemented
    }
    
    
    // ------------------------------------------------
    // PLUS BUTTON
    // ------------------------------------------------
    @IBAction func plusButt(_ sender: UIButton) {
        //Not currently implemented
    }
    
    
    // ------------------------------------------------
    // BACK TO SHOP BUTTON
    // ------------------------------------------------
    @IBAction func backToShopButt(_ sender: Any) {
        // Dismiss
        self.dismiss(animated: true, completion: nil)
    }
    
    
   
    
    // ------------------------------------------------
    // EDIT SHIPPING ADDRESS BUTTON
    // ------------------------------------------------
    @IBAction func editShippingAddressButt(_ sender: Any) {

    }
    
    
    
    
    
    // ------------------------------------------------
    // DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButt(_ sender: Any) {
        ProductBridge.clearCart()
        dismiss(animated: true, completion: nil)
    }
    
    
}// ./ end
