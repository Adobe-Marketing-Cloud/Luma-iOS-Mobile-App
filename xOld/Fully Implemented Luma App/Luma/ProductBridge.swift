//
//  ProductBridge.swift
//  Luma
//
//  Created by Raymond Piccolotti on 1/28/22.
//  Copyright © 2022 xscoder. All rights reserved.
//

import Foundation
import Parse

class ProductBridge
{
    static var cartArray = [PFObject]()
    
    static func getCartArray() -> [PFObject]{
        return cartArray;
    }
    static func addToCart(input:PFObject){
        cartArray.append(input)
    }
    static func removeFromCart(input:PFObject){
        //to do
    }
    static func clearCart(){
        cartArray.removeAll()
    }
    
    static func loadProducts(){
                
                //Clear
                do{
                    try PFObject.unpinAllObjects()
                }catch{
                    print(error)
                }
                

                do {
                    //Decode JSON
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(ListOfProducts.self,
                                                               from: productData)

                    for currentProduct in decodedResponse.items {
                        let pfProduct = PFObject(className:"Products")
                        pfProduct["objectId"] = currentProduct.objectId
                        pfProduct["createdAt"] = currentProduct.createdAt
                        pfProduct["updatedAt"] = currentProduct.updatedAt
                        pfProduct["name"] = currentProduct.name
                        pfProduct["currency"] = currentProduct.currency
                        pfProduct["finalPrice"] = currentProduct.finalPrice
                        pfProduct["isFeatured"] = currentProduct.isFeatured
                        pfProduct["description"] = currentProduct.description
                        pfProduct["category"] = currentProduct.category
                        pfProduct["subCategory"] = currentProduct.subCategory
                        pfProduct["isOutOfStock"] = currentProduct.isOutOfStock

                        pfProduct["image1"] = currentProduct.image1.name
        //                pfProduct["image2"] = currentProduct.image2;
        //                pfProduct["image3"] = currentProduct.image3;
        //                if(currentProduct.image4 != nil){
        //                    pfProduct["image4"] = currentProduct.image4
        //                }
        //                pfProduct["wishlistedBy"] = currentProduct.wishlistedBy;
                        if(currentProduct.SKU != nil){
                            pfProduct["SKU"] = currentProduct.SKU
                        }
                        
                        pfProduct.pinInBackground()
                    }


                } catch {
                    print(error)
                }
    }
}

struct ListOfProducts: Decodable {
    let items: [Product]
}

struct Image: Decodable {
    let __type: String
    let name: String
    let url: String

}

struct Product: Decodable {
    let objectId: String
    let createdAt: String
    let updatedAt: String
    let name: String
    let currency: String
    let finalPrice: Int
    let description: String
    let isFeatured: Bool
    let category: String
    let subCategory: String
    let isOutOfStock: Bool
    let image1: Image
    let image2: Image?
    let image3: Image?
    let image4: Image?
    let wishlistedBy: [String]?
    let SKU: [String]?
}

let productData = """
{
"items" : [
  {
    "objectId": "exvDH7wllU",
    "name": "Luma Yoga For Life",
    "createdAt": "2018-10-26T11:26:11.898Z",
    "updatedAt": "2021-08-16T21:08:14.825Z",
    "finalPrice": 29,
    "currency": "$",
    "image1": {
      "__type": "File",
      "name": "08074a66ab70918d90b69fd9cec36d13_lt06.jpeg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/08074a66ab70918d90b69fd9cec36d13_lt06.jpeg"
    },
    "isFeatured": true,
    "description": "Tone up mind and bodyPro Yoga Instructor and Master Practitioner Marie Peale helps tone and sculpt your physique with her invigorating yet gentle approach.You'll learn to use yoga to relax, control stress and increase your calorie-burning capacity, all while exploring traditional and new yoga poses that lengthen and strengthen your full muscular structure.Easy downloadAudio options: Music and instruction or instruction onlyHeart rate techniques explainedBreathing techniques explainedMove through exercises at your own pace",
    "category": "Training",
    "wishlistedBy": [
      "ahu8t28TKo"
    ],
    "subCategory": "fitness",
    "isOutOfStock": false
  },
  {
    "objectId": "KeX55qRbH3",
    "name": "Miko Pullover Hoodie",
    "createdAt": "2018-10-29T14:22:30.315Z",
    "updatedAt": "2021-06-10T17:01:20.397Z",
    "currency": "$",
    "finalPrice": 69,
    "image1": {
      "__type": "File",
      "name": "6e1175e31b6490567d855cb45cc875bd_wh04-blue_main.jpeg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/6e1175e31b6490567d855cb45cc875bd_wh04-blue_main.jpg"
    },
    "image2": {
      "__type": "File",
      "name": "66b7ea12c75324ac04b48e037d15e3eb_wh04-blue_alt1.jpg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/66b7ea12c75324ac04b48e037d15e3eb_wh04-blue_alt1.jpg"
    },
    "isFeatured": true,
    "image3": {
      "__type": "File",
      "name": "54eeffefa7d9d0027c9294607afe600b_wh04-blue_back.jpg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/54eeffefa7d9d0027c9294607afe600b_wh04-blue_back.jpg"
    },
    "description": "After quality gym time, put on the Miko Pullover Hoody and keep your body warm. You'll find it's fashionable enough for the streets, but comfy enough to relax in at home.• Teal two-tone hoodie.• Low scoop neckline.• Adjustable hood drawstrings.• Longer rounded hemline for extra back coverage.• Long-Sleeve style.",
    "category": "Women",
    "wishlistedBy": [
      "0bDHDKwbFG"
    ],
    "subCategory": "tops",
    "isOutOfStock": false
  },
  {
    "objectId": "Vt6VOFHaZt",
    "category": "Gear",
    "createdAt": "2018-10-29T14:29:23.436Z",
    "updatedAt": "2021-06-15T21:32:40.914Z",
    "description": "Everything you need for a trip to the gym will fit inside this surprisingly spacious Voyage Yoga Bag. Stock it with a water bottle, change of clothes, pair of shoes, and even a few beauty products. Fits inside a locker and zips shut for security.Slip pocket on front.Contrast piping.Durable nylon construction.",
    "name": "Voyage Yoga Bag",
    "currency": "$",
    "finalPrice": 32,
    "image1": {
      "__type": "File",
      "name": "e20a0bd9b98530ec232bb74fa1e815eb_wb01-black-0.jpeg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/e20a0bd9b98530ec232bb74fa1e815eb_wb01-black-0.jpeg"
    },
    "isFeatured": true,
    "wishlistedBy": [
      "XAGFDbNjd4",
      "0bDHDKwbFG",
      "4XdweOva9L"
    ],
    "subCategory": "fitness",
    "isOutOfStock": false
  },
  {
    "objectId": "3pFN118KRH",
    "name": "Set of Sprite Yoga Straps",
    "createdAt": "2018-10-29T14:33:04.187Z",
    "updatedAt": "2021-06-10T17:01:05.865Z",
    "currency": "$",
    "finalPrice": 14,
    "image1": {
      "__type": "File",
      "name": "e0869bf00255542bdb38cbaa927ed95a_luma-yoga-strap-set.jpeg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/e0869bf00255542bdb38cbaa927ed95a_luma-yoga-strap-set.jpeg"
    },
    "isFeatured": true,
    "description": "Great set of Sprite Yoga Straps for every stretch and hold you need. There are three straps in this set: 6', 8' and 10'.100% soft and durable cotton.Plastic cinch buckle is easy to use.Choice of three natural colors made from phthalate and heavy metal free dyes.",
    "category": "Gear",
    "wishlistedBy": [
      "XAGFDbNjd4",
      "0bDHDKwbFG"
    ],
    "subCategory": "fitness",
    "isOutOfStock": false
  },
  {
    "objectId": "TU607TnOiF",
    "createdAt": "2018-12-02T00:33:37.678Z",
    "updatedAt": "2021-06-10T17:01:30.098Z",
    "name": "Jupiter All-Weather Trainer (Blue)",
    "currency": "$",
    "finalPrice": 56,
    "image1": {
      "__type": "File",
      "name": "e051de68bcc8718e4c9d0b3a2803b941_mj06-blue_main.jpg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/e051de68bcc8718e4c9d0b3a2803b941_mj06-blue_main.jpg"
    },
    "isFeatured": false,
    "category": "Men",
    "description": "Inclement climate be damned. With your breathable, water-resistant Jupiter All-Weather Trainer, you can focus on fuel and form and leave protection and comfort to us. The fabric is a special light fleece that wicks moisture and insulates at once.• Relaxed fit.• Hand pockets.• Machine wash/dry.• Reflective safety trim.",
    "wishlistedBy": [
      "0bDHDKwbFG",
      "1SbpNHeCZN"
    ],
    "subCategory": "bottoms",
    "isOutOfStock": false
  },
  {
    "objectId": "C2bF3wUVpE",
    "createdAt": "2018-12-02T00:36:28.630Z",
    "updatedAt": "2021-06-10T17:01:13.203Z",
    "name": "Proteus Fitness Jackshirt (Orange)",
    "currency": "$",
    "finalPrice": 45,
    "image1": {
      "__type": "File",
      "name": "81b91e817aac9a8cd090723111085cdd_mj12-orange_main.jpeg",
      "url": "https://parsefiles.back4app.com/tBhfIrZLASH0piZXPME9cP4COAu5jFBotHIrsBe5/81b91e817aac9a8cd090723111085cdd_mj12-orange_main.jpeg"
    },
    "isFeatured": true,
    "description": "Part jacket, part shirt, the Proteus Fitness Jackshirt makes an ideal companion for outdoor training, camping or loafing on crisp days. Natural Cocona® technology brings breathable comfort and increased dryness along with UV protection and odor management. The drop-tail hem provides extra coverage when you're riding a bike or replacing a sink valve.• 1/4 zip. Stand-up collar.• Machine wash/dry.• Quilted inner layer.",
    "category": "Men",
    "wishlistedBy": [],
    "subCategory": "tops",
    "isOutOfStock": false
  }
]
}
""".data(using: .utf8)!
