//
//  OrderDetails.swift
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


class OrderDetails: UIViewController {

    /*--- VIEWS ---*/
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var oDateLabel: UILabel!
    @IBOutlet weak var oIDLabel: UILabel!
    @IBOutlet weak var oTotalLabel: UILabel!
    @IBOutlet weak var leaveFeedbackButton: UIButton!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var shippingAddressLabel: UILabel!
    
    @IBOutlet weak var trackShipmentButton: UIButton!
    
    
    
    
    /*--- VARIABLES ---*/
    var orderObj = PFObject(className: ORDERS_CLASS_NAME)
    
    
    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------+
    override func viewDidAppear(_ animated: Bool) {
        // Call query
        showOrderDetails()
        
        // Adobe Experience Platform - Send XDM Event
        let stateName = "luma: content: ios: us: orderdetails"
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
    // VIEW DI LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout
        leaveFeedbackButton.layer.cornerRadius = 8
        trackShipmentButton.layer.cornerRadius = 8

        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                                 height: 1000)
        
    }

    
    
    
    // ------------------------------------------------
    // SHOW ORDER'S DETAILS
    // ------------------------------------------------
    func showOrderDetails() {
        // productPointer
        let prodPointer = orderObj[ORDERS_PRODUCT_POINTER] as! PFObject
        prodPointer.fetchIfNeededInBackground { (object, error) in
            if error == nil {

                // Order Date
                let date = self.orderObj.createdAt!
                let df = DateFormatter()
                df.dateFormat = "MMM dd yyy | hh:mm a"
                self.oDateLabel.text = "Order date: " + df.string(from: date)
                
                // Order ID
                self.oIDLabel.text = "Order ID: \(self.orderObj.objectId!)"
                
                // Order Total
                let price = prodPointer[PRODUCTS_FINAL_PRICE] as! Double
                let qty = self.orderObj[ORDERS_PRODUCT_QTY] as! Double
                let totalPrice = price * qty
                let formattedTotal = Double(round(1000 * totalPrice) / 1000)
                self.oTotalLabel.text = "Order Total : \(CURRENCY_CODE) \(formattedTotal)"
                
                // Feedback button
                let feedbackLeft = self.orderObj[ORDERS_FEEDBACK_LEFT] as! Bool
                if feedbackLeft {
                    self.leaveFeedbackButton.isHidden = true
                } else {
                    self.leaveFeedbackButton.isHidden = false
                }
                
                // Delivery info
                self.deliveryDateLabel.text = "\(self.orderObj[ORDERS_DELIVERY_DATE]!)"
                
                // Payment info
                self.paymentLabel.text = "Paid with PayPal® on " + df.string(from: date)
                
                // Shipping address
                self.shippingAddressLabel.text = "\(self.orderObj[ORDERS_SHIPPING_ADDRESS]!)"
                
                
        }}// ./ prodPointer
    }
    
    
    
    
    // ------------------------------------------------
    // LEAVE FEEDBACK BUTTON
    // ------------------------------------------------
    @IBAction func leaveFeedbackButt(_ sender: UIButton) {

    }
    
    
    
    
    // ------------------------------------------------
    // TRACK SHIPMENT BUTTON
    // ------------------------------------------------
    @IBAction func trackShipmentButt(_ sender: Any) {
    }
    
    
    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
}// ./ end
