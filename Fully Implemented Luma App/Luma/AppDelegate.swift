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

//Adobe AEP SDKs
import AEPUserProfile
import AEPAssurance
import AEPEdge
import AEPCore
import AEPEdgeIdentity
import AEPEdgeConsent
import AEPIdentity
import AEPLifecycle
import AEPMessaging
import AEPSignal
import AEPServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Adobe Experience Platform - Config
        MobileCore.setLogLevel(.trace)
        //Replace with your tags app id - details provided in tutorial
        let currentAppId = "b5cbd1a1220e/bae66382cce8/launch-88492c6dcb6e-development"


        let extensions = [Edge.self, Assurance.self, UserProfile.self, Consent.self, AEPEdgeIdentity.Identity.self, AEPIdentity.Identity.self, Messaging.self]

        let appState = application.applicationState
        MobileCore.registerExtensions(extensions, {
            MobileCore.configureWith(appId: currentAppId)
            if appState != .background {
                // only start lifecycle if the application is not in the background
                var addData: [String: Any] = [:]
                addData["customAppID"] = "1.2.3"
                MobileCore.lifecycleStart(additionalContextData: addData)
            }
        })

        // Adobe Experience Platform - Profile - Get
        UserProfile.getUserAttributes(attributeNames: ["isPaidUser","loyaltyLevel"]){
            attributes, error in
            print("Profile: getUserAttributes: ",attributes as Any)
        }

        // Adobe Experience Platform - Identity - Get Email
        //Get email identities
        Identity.getIdentities { identityMap, error in
            if let items = identityMap?.getItems(withNamespace: "Email") {
                for current in items{
                    print("Identity getIdentities: ", current.id," Auth?:",current.authenticatedState," Primary?: "+String(current.primary))
                }
            }
        }
        
        
        loadProducts()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Adobe Experience Platform - Assurance start session
        Assurance.startSession(url: url)
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
