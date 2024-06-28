//
//  AppDelegate.swift
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

import AEPCore
import AEPEdge
import AEPEdgeConsent
import AEPAssurance
import AEPEdgeIdentity
import AEPIdentity
import AEPLifecycle
import AEPSignal
import AEPServices
import AEPUserProfile

@AppStorage("environmentFileId") private var environmentFileId = "666644a00be2/1652228d142c/launch-b2835312c7d3-development"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadProducts()
        MobileCore.setLogLevel(.debug)
        let appState = application.applicationState
        let extensions = [
                          Edge.self,
                          Consent.self,
                          Assurance.self,
                          AEPEdgeIdentity.Identity.self,
                          AEPIdentity.Identity.self,
                          Lifecycle.self,
                          Signal.self,
                          UserProfile.self
                        ]
        MobileCore.registerExtensions(extensions, {
            MobileCore.configureWith(appId: "666644a00be2/1652228d142c/launch-b2835312c7d3-development")
            if appState != .background {
                MobileCore.lifecycleStart(additionalContextData: ["contextDataKey": "contextDataVal"])
            }
        })

        
        return true
    }
    

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadProducts() {
        //Perviously used remote backend, made local
        let configuration = ParseClientConfiguration {
            $0.applicationId = "parseAppId"
            $0.clientKey = "parseClientKey"
            $0.server = "https://parseapi.back4app.com"
            $0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: configuration)
        ProductBridge.loadProducts()
    }

}

extension AppDelegate {

    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        self.window?.rootViewController!.present(alert, animated: true, completion: nil)
        
    }
    
    
}
