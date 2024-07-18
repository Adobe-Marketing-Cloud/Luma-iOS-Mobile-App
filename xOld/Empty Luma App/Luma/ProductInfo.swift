//
//  ProductInfo.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//

import UIKit
import Parse
import UserNotifications

class ProductInfo: UIViewController {

    /*--- VIEWS ---*/
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    @IBOutlet weak var prodPriceLabel: UILabel!
    @IBOutlet weak var prodDescriptionTxt: UITextView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet var sizeButtons: [UIButton]!
    
    
    
    /*--- VARIABLES ---*/
    var pObj = PFObject(className: PRODUCTS_CLASS_NAME)
    var isRemoveFromCart = false
    var selectedSize = ""
    
    
    var tempImage = ""
    
    
    // ------------------------------------------------
    // HIDE STATUS BAR
    // ------------------------------------------------
    override var prefersStatusBarHidden : Bool {
        return true
    }

    
    // ------------------------------------------------
    // VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        // Check this product and show its details
        checkifProductIsInCart()
    }
    
    
    // ------------------------------------------------
    // VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        // Layout
        addToCartButton.layer.cornerRadius = 8
        
        for butt in sizeButtons {
            butt.layer.cornerRadius = 3
        }
        
        
        // Show product details
        showProdcutInfo()

    }

    
    // ------------------------------------------------
    // SHOW PRODUCT INFO
    // ------------------------------------------------
    func showProdcutInfo() {
        // Main Image
        getParseImage(object: pObj, colName: PRODUCTS_IMAGE1, imageView: mainImage)
        print ("image URL is " + tempImageURL)
        // Name
        prodNameLabel.text = "\(pObj[PRODUCTS_NAME]!)"
        
        // Price
        let price = pObj[PRODUCTS_FINAL_PRICE] as! Double
        prodPriceLabel.text = "\(pObj[PRODUCTS_CURRENCY]!) \(price)"
        
        // Desription
        prodDescriptionTxt.text = "\(pObj[PRODUCTS_DESCRIPTION]!)"
        
    }

    
    
    
    // ------------------------------------------------
    // SELECT SIZE BUTTON
    // ------------------------------------------------
    @IBAction func selectSizeButt(_ sender: UIButton) {
        selectedSize = sender.titleLabel!.text!
        
        for butt in sizeButtons {
            butt.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
            butt.setTitleColor(UIColor.white, for: .normal)
        }
        sender.backgroundColor = UIColor.white
        sender.setTitleColor(UIColor.black, for: .normal)
    }
    

    
    // ------------------------------------------------
    // CART BUTTON
    // ------------------------------------------------
    @IBAction func cartButt(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Cart") as! Cart
        present(vc, animated: true, completion: nil)
    }
    

    
    
    
    // ------------------------------------------------
    // ADD TO / REMOVE FROM CART BUTTON
    // ------------------------------------------------
    @IBAction func addToCartButt(_ sender: AnyObject) {
            // ADD PRODUCT TO CART
            if !isRemoveFromCart {
                
                // Size HAS been selected
                if selectedSize != "" {
                    // Parse Obj
                    let cartObj = PFObject(className: CART_CLASS_NAME)
                    //let currentUser = PFUser.current()
                    
                    //cartObj[CART_USER_POINTER] = currentUser
                    cartObj[CART_PRODUCT_POINTER] = pObj
                    cartObj[CART_PRODUCT_QTY] = 1
                    cartObj[CART_PRODUCT_SIZE] = selectedSize
                    let price = pObj[PRODUCTS_FINAL_PRICE] as! Double
                    cartObj[CART_TOTAL_AMOUNT] = price
                    
                    ProductBridge.addToCart(input: pObj)
                    self.simpleAlert("Product Added to Cart")
             
                // Size has NOT been selected
                } else {
                    hideHUD()
                    simpleAlert("Please select a Size.")
                }
                
                
            // REMOVE PRODUCT FROM CART
            } else {
                ProductBridge.removeFromCart(input: pObj)
                self.simpleAlert("Product Removed from Cart")
                
            }

    }
    

    
    
    
    // ------------------------------------------------
    // GALLERY BUTTON
    // ------------------------------------------------
    @IBAction func galleryButt(_ sender: Any) {

    }
    
    
    
    
    // ------------------------------------------------
    // FEEDBACKS BUTTON
    // ------------------------------------------------
    @IBAction func feedbacksButt(_ sender: Any) {

    }
    
    
    
    
    
    // ------------------------------------------------
    // ADD TO WISHLIST BUTTON
    // ------------------------------------------------
    @IBAction func addToWishlistButt(_ sender: AnyObject) {
        
    }
    
    
    
    
    // ------------------------------------------------
    // BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }

    // ------------------------------------------------
    // CHECK IF PRODUCT IS IN CART
    // ------------------------------------------------
    func checkifProductIsInCart() {
        //Not currently functional
        self.addToCartButton.setTitle("Add to Cart", for: .normal)
        self.isRemoveFromCart = false
    }
    
    
}// ./ end
