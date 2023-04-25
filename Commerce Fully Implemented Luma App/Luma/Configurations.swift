//
//  Configuration.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import Foundation
import UIKit
import Parse


// ------------------------------------------------
// REPLACE THE STRING BELOW WITH THE NEW NAME YOU'LL GIVE TO THIS APP
// ------------------------------------------------
let APP_NAME = "Luma"


// ------------------------------------------------
// REPLACE THE STRINGS BELOW WEITH THE APP ID AND CLIENT KEY OF YOUR PARSE APP ON https://back4app.com
// ------------------------------------------------
var PARSE_APP_KEY = ""
var PARSE_CLIENT_KEY = ""

// ------------------------------------------------
// EDIT THE RGBA VALUES BELOW AS YOU WISH
// ------------------------------------------------
let MAIN_COLOR = UIColor(red: 245/255, green: 75/255, blue: 143/255, alpha: 1)
let LIGHT_GREY = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)

// ------------------------------------------------
// REPLACE "USD" WITH YOUR OWN CURRENCY (IN CASE YOUR STORE IS NOT LOCATED IN THE U.S.)
// ------------------------------------------------
let CURRENCY_CODE = "USD"


// ------------------------------------------------
// YOU CAN CHANGE THIS FIXED DELIVERY PRICE AS YOU WISH
// ------------------------------------------------
let DELIVERY_PRICE = 7.90


// ------------------------------------------------
// BY DEFAULT, THE ESTIMATED NUMBER OF DELIVERY DATE IS 2, BUT YOU CAN CHANGE IT AS YOU WISH
// ------------------------------------------------
let DEFAULT_ESTIMATED_DELIVERY_DAYS = 2


// ------------------------------------------------
// REPLACE THE RED NAME BELOW WITH THE ONE OF YOUR STORE/COMPANY
// ------------------------------------------------
let MERCHANT_NAME = "Luma"

var isLoggedIn = false;

// ------------------------------------------------
// UTILITY EXTENSIONS
// ------------------------------------------------
var hud = UIView()
var loadingCircle = UIImageView()
var toast = UILabel()

extension UIViewController {
    // ------------------------------------------------
    // SHOW TOAST MESSAGE
    // ------------------------------------------------
    func showToast(_ message:String) {
        toast = UILabel(frame: CGRect(x: view.frame.size.width/2 - 100,
                                      y: view.frame.size.height-100,
                                      width: 200,
                                      height: 32))
        toast.font = UIFont(name: "OpenSans-Bold", size: 14)
        toast.textColor = UIColor.white
        toast.textAlignment = .center
        toast.adjustsFontSizeToFitWidth = true
        toast.text = message
        toast.layer.cornerRadius = 14
        toast.clipsToBounds = true
        toast.backgroundColor = MAIN_COLOR
        view.addSubview(toast)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideToast), userInfo: nil, repeats: false)
    }
    @objc func hideToast() {
        toast.removeFromSuperview()
    }
    
    // ------------------------------------------------
    // SHOW/HIDE LOADING HUD
    // ------------------------------------------------
    func showHUD() {
        hud.frame = CGRect(x:0, y:0,
                           width:view.frame.size.width,
                           height: view.frame.size.height)
        hud.backgroundColor = UIColor.white
        hud.alpha = 0.7
        view.addSubview(hud)
        
        loadingCircle.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingCircle.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        loadingCircle.image = UIImage(named: "loading_circle")
        loadingCircle.contentMode = .scaleAspectFill
        loadingCircle.clipsToBounds = true
        animateLoadingCircle(imageView: loadingCircle, time: 0.8)
        view.addSubview(loadingCircle)
    }
    func animateLoadingCircle(imageView: UIImageView, time: Double) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = -Double.pi * 2
        rotationAnimation.duration = time
        rotationAnimation.repeatCount = .infinity
        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    func hideHUD() {
        hud.removeFromSuperview()
        loadingCircle.removeFromSuperview()
    }
    
    
    // ------------------------------------------------
    // SHOW LOGIN ALERT
    // ------------------------------------------------
    func showLoginAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
            message: mess,
            preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            self.present(aVC, animated: true, completion: nil)
        })
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // ------------------------------------------------
    // FIRE A SIMPLE ALERT
    // ------------------------------------------------
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // ------------------------------------------------
    // GET PARSE IMAGE - IMAGEVIEW
    // ------------------------------------------------
    func getParseImage(object:PFObject, colName:String, imageView:UIImageView) {
        let location = object["image1"] as! String
        
        if let url = URL(string: location) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              // Error handling...
              guard let imageData = data else { return }

              DispatchQueue.main.async {
                  imageView.image = UIImage(data: imageData)
              }
            }.resume()
          }
    }
    
    func getParseImage(location:String, colName:String, imageView:UIImageView) {
        if let url = URL(string: location) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              // Error handling...
              guard let imageData = data else { return }

              DispatchQueue.main.async {
                  imageView.image = UIImage(data: imageData)
              }
            }.resume()
          }
    }
    
    // ------------------------------------------------
    // GET PARSE IMAGE - BUTTON
    // ------------------------------------------------
    func getParseImage(object:PFObject, colName:String, button:UIButton) {

        let location = object["image1"] as! String
        let image = UIImage(named: location)
        button.setImage(image, for: .normal)
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
    }
    
    
    // ------------------------------------------------
    // SAVE PARSE IMAGE
    // ------------------------------------------------
    func saveParseImage(object:PFObject, colName:String, imageView:UIImageView) {
//        let imageData = imageView.image!.jpegData(compressionQuality: 1.0)
//        let imageFile = PFFile(name:"image.jpg", data:imageData!)
//        object[colName] = imageFile
    }
    
    // ------------------------------------------------
    // PROPORTIONALLY SCALE AN IMAGE TO MAX WIDTH
    // ------------------------------------------------
    func scaleImageToMaxWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // ------------------------------------------------
    // FORMAT DATE BY TIME AGO SINCE DATE
    // ------------------------------------------------
    func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){ return "1 year ago"
            } else { return "Last year" }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){ return "1 month ago"
            } else { return "Last month" }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){ return "1 week ago"
            } else { return "Last week" }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){ return "1 day ago"
            } else { return "Yesterday" }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){ return "1 hour ago"
            } else { return "An hour ago" }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){ return "1 minute ago"
            } else { return "A minute ago" }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else { return "Just now" }
    }
    
    
    // ------------------------------------------------
    // SET CELL SIZE
    // ------------------------------------------------
    func setCellSize() -> CGSize {
        var cellSize = CGSize()
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellSize = CGSize(width: view.frame.size.width/3 - 20, height: 250)
        } else {
            cellSize = CGSize(width: view.frame.size.width/2 - 20, height: 250)
        }
        return cellSize
    }
    
}// ./ extension UIViewController



// ------------------------------------------------
// EXTENSION TO FORMAT LARGE NUMBERS
// ------------------------------------------------
extension Int {
    var rounded:String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}






// ------------------------------------------------
// PARSE DASHBOARD CLASSES AND COLUMN NAMES
// ------------------------------------------------
let USER_CLASS_NAME = "_User"
let USER_AVATAR = "avatar"
let USER_USERNAME = "username"
let USER_EMAIL = "email"
let USER_FULLNAME = "fullName"
let USER_SHIPPING_ADDRESS = "shippingAddress"

let CATEGORIES_CLASS_NAME = "Categories"
let CATEGORIES_CATEGORY = "category"
let CATEGORIES_IMAGE = "image"

let PRODUCTS_CLASS_NAME = "Products"
let PRODUCTS_CATEGORY = "category"
let PRODUCTS_NAME = "name"
let PRODUCTS_IMAGE1 = "image1"
let PRODUCTS_IMAGE2 = "image2"
let PRODUCTS_IMAGE3 = "image3"
let PRODUCTS_IMAGE4 = "image4"
let PRODUCTS_FINAL_PRICE = "finalPrice"
let PRODUCTS_CURRENCY = "currency"
let PRODUCTS_DESCRIPTION = "description"
let PRODUCTS_KEYWORDS = "keywords"
let PRODUCTS_IS_FEATURED = "isFeatured"
let PRODUCTS_WISHLISTED_BY = "wishlistedBy"
let PRODUCTS_SKU = "SKU"

let CART_CLASS_NAME = "Cart"
let CART_TOTAL_AMOUNT = "totalAmount"
let CART_PRODUCT_POINTER = "productPointer"
let CART_PRODUCT_QTY = "qty"
let CART_PRODUCT_SIZE = "size"
let CART_USER_POINTER = "userPointer"

let ORDERS_CLASS_NAME = "Orders"
let ORDERS_USER_POINTER = "userPointer"
let ORDERS_PAYMENT_PROOF = "paymentProof"
let ORDERS_PRODUCT_POINTER = "prodPointer"
let ORDERS_PRODUCT_QTY = "qty"
let ORDERS_PRODUCT_SIZE = "size"
let ORDERS_FEEDBACK_LEFT = "feedbackLeft"
let ORDERS_DELIVERY_DATE = "deliveryDate"
let ORDERS_TRACKING_NUMBER = "trackingNumber"
let ORDERS_SHIPPING_ADDRESS = "shippingAddress"

let FEEDBACKS_CLASS_NAME = "Feedbacks"
let FEEDBACKS_USER_POINTER = "userPointer"
let FEEDBACKS_PRODUCT_POINTER = "productPointer"
let FEEDBACKS_FEEDBACK = "feedback"
let FEEDBACKS_STARS = "stars"

let STORES_CLASS_NAME = "store"
let STORES_STORENAME = "name"
let STORES_STOREID = "storeId"



/* GLOBAL VARIABLES */
var tempImageURL = ""
var productCategory = "Women"

/* CONFIGURATION VARIABLES */
let GRAPHQL_ENDPOINT = Bundle.main.object(forInfoDictionaryKey: "ServerURL") as! String


func string (_ dict:NSDictionary, _ key:String) -> String {
    if let title = dict[key] as? String {
        return "\(title)"
    } else if let title = dict[key] as? NSNumber {
        return "\(title)"
    } else {
        return ""
    }
}
func number (_ dict:NSDictionary, _ key:String) -> NSNumber {
    if let title = dict[key] as? NSNumber {
        return title
    } else if let title = dict[key] as? String {
        
        if let title1 = Int(title) as Int? {
            return NSNumber(value: title1)
        } else if let title1 = Float(title) as Float? {
            return NSNumber(value: title1)
        } else if let title1 = Double(title) as Double? {
            return NSNumber(value: title1)
        } else if let title1 = Bool(title) as Bool? {
            return NSNumber(value: title1)
        }
        
        return 0
    } else {
        return 0
    }
}
