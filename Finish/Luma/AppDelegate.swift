//
//  AppDelegate.swift
//  Luma
//
//  Created by Rob In der Maur on 30/05/2022.
//

// import AEP MobileSDK libraries
import AEPCore
import AEPServices
import AEPIdentity
import AEPSignal
import AEPLifecycle
import AEPEdge
import AEPEdgeIdentity
import AEPEdgeConsent
import AEPUserProfile
import AEPPlaces
import AEPMessaging
import AEPOptimize
import AEPAssurance

import UIKit
import SwiftUI
import AVKit
import AdSupport
import UserNotifications
import os.log

class AppDelegate: UIResponder, UIApplicationDelegate {
    @AppStorage("environmentFileId") private var environmentFileId = "b5cbd1a1220e/1857ef6cacb5/launch-2594f26b23cd-development"
    @AppStorage("currentDeviceToken") private var currentDeviceToken = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        MobileCore.setLogLevel(.trace)
        let appState = application.applicationState;
        
        // Define extensions
        let extensions = [
            // Analytics.self,
            AEPIdentity.Identity.self,
            Lifecycle.self,
            Signal.self,
            Edge.self,
            AEPEdgeIdentity.Identity.self,
            Consent.self,
            UserProfile.self,
            Places.self,
            Messaging.self,
            Optimize.self,
            Assurance.self
        ]
        
        // Register extensions
        MobileCore.registerExtensions(extensions, {
            // Use the environment file id assigned to this application via Adobe Experience Platform Data Collection
            Logger.aepMobileSDK.info("Luma - using mobile config: \(self.environmentFileId)")
            MobileCore.configureWith(appId: self.environmentFileId)
            
            // set this to false or comment it when deploying to TestFlight (default is false),
            // set this to true when testing on your device.
            MobileCore.updateConfigurationWith(configDict: ["messaging.useSandbox": true])
            if appState != .background {
                // only start lifecycle if the application is not in the background
                MobileCore.lifecycleStart(additionalContextData: nil)
            }
            
            // assume unknown, adapt to your needs.
            MobileCore.setPrivacyStatus(.unknown)
        })
        
        // update version and build
        Logger.configuration.info("Luma - Updating version and build number...")
        SettingsBundleHelper.setVersionAndBuildNumber()
        
        // register push notification
        registerForPushNotifications(application: application)
        
        // set up core location
        let locationManager = LocationManager()
        locationManager.requestAuthorisation()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Register for push notification
    func registerForPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) {
            [weak self] granted, _ in
            guard granted else { return }
            
            center.delegate = self
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Required to log the token
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Logger.notifications.info("didRegisterForRemoteNotificationsWithDeviceToken - device token: \(token)")
        
        // Send push token to Mobile SDK
        MobileCore.setPushIdentifier(deviceToken)
        
        currentDeviceToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.notifications.info("didFailToRegisterForRemoteNotificationsWithError - Error \(error)")
    }
    
    func scheduleNotification() {
        Logger.notifications.info("AppDelegate - scheduleNotification()")
        let content = UNMutableNotificationContent()

        content.title = "Notification Title"
        content.body = "This is example how to create "

        content.userInfo = ["_xdm": ["cjm": ["_experience": ["customerJourneyManagement":
            ["messageExecution": ["messageExecutionID": "16-Sept-postman", "messageID": "567",
                                  "journeyVersionID": "some-journeyVersionId", "journeyVersionInstanceId": "someJourneyVersionInstanceId"]]]]]]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.notifications.info("scheduleNotification - Error \(error.localizedDescription)…")
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.configuration.info("applicationDidBecomeActive - Updating version and bulld number...")
        SettingsBundleHelper.setVersionAndBuildNumber()
    }
    
    func scheduleNotificationWithCustomAction() {
        Logger.notifications.info("AppDelegate - scheduleNotificationWithCustomAction()")
        let content = UNMutableNotificationContent()

        content.title = "Notification Title"
        content.body = "This is example how to create "
        content.categoryIdentifier = "MEETING_INVITATION"
        content.userInfo = ["_xdm": ["cjm": ["_experience": ["customerJourneyManagement":
            ["messageExecution": ["messageExecutionID": "16-Sept-postman", "messageID": "567",
                                  "journeyVersionID": "some-journeyVersionId", "journeyVersionInstanceId": "someJourneyVersionInstanceId"]]]]]]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        let meetingInviteCategory =
            UNNotificationCategory(identifier: "MEETING_INVITATION",
                                   actions: [acceptAction, declineAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])

        notificationCenter.add(request) { error in
            if let error = error {
                Logger.aepMobileSDK.info("scheduleNotificationWithCustomAction - Error \(error.localizedDescription)…")
            }
        }
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Perform the task associated with the action.
        Logger.notifications.info("AppDelegate - userNotificationCenter")
        switch response.actionIdentifier {
           case "ACCEPT_ACTION":
                // If using AEP Messaging version 5 or later, remove the following parameters: 
                // ", applicationOpened: true, customActionId: "ACCEPT_ACTION"" 
                Messaging.handleNotificationResponse(response, applicationOpened: true, customActionId: "ACCEPT_ACTION")

            case "DECLINE_ACTION":
                // If using AEP Messaging version 5 or later, remove the following parameters: 
                // ", applicationOpened: false, customActionId: "DECLINE_ACTION"" 
                Messaging.handleNotificationResponse(response, applicationOpened: false, customActionId: "DECLINE_ACTION")

            // Handle other actions…
            default:
                // If using AEP Messaging version 5 or later, remove the following parameters: 
                // ", applicationOpened: true, customActionId: nil"" 
                Messaging.handleNotificationResponse(response, applicationOpened: true, customActionId: nil)
            }
        }

        let userInfo = response.notification.request.content.userInfo
        Logger.notifications.info("AppDelegate - userNotificationCenter - userInfo: \(userInfo.description)")
        // Always call the completion handler when done.
        completionHandler()
    }
}

// Extension tells app to be able to get notification when in use and also for extensions
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Logger.notifications.info("AppDelegate - userNotificationCenter:willPresent:withCompletionHandler")
        completionHandler([.banner, .sound])
    }
}



