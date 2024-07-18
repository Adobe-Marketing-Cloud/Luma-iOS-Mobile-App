//
//  SettingsBundleHelper.swift
//  Luma
//
//  Created by Mathieu Hannouz on 6/5/19.
//  Copyright © 2019 xscoder. All rights reserved.
//

import Foundation
class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let LaunchID = "launch_propertyId"
        static let EstimoteAppID = "estimote_appId"
        static let EstimoteAppToken = "estimote_appToken"
    }
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.Reset) {
            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.Reset)
            let appDomain: String? = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            // reset userDefaults..
            // CoreDataDataModel().deleteAllData()
            // delete all other user data here..
        }
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
}
