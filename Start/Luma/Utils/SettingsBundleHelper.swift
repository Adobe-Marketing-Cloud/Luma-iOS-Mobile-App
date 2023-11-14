//
//  SettingsBundleHelper.swift
//  Luma
//
//  Created by Rob In der Maur on 21/10/2022.
//

import SwiftUI

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let Reset = "RESET_APP_KEY"
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
        static let DevelopmentTeamKey = "development_preference"
        static let UseTestConfigKey = "testconfig_preference"
    }
    
    
    /// Checks and execute settings for information in App Settings
    class func checkAndExecuteSettings() {
        // if UserDefaults.standard.bool(forKey: SettingsBundleKeys.Reset) {
            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.Reset)
            let appDomain: String? = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            // reset userDefaults..
            // CoreDataDataModel().deleteAllData()
            // delete all other user data here..
        // }
    }
    
    /// Set version and build number
    class func setVersionAndBuildNumber() {
        let version: String = UIApplication.appVersion ?? "1.0.0"
        UserDefaults.standard.set(version, forKey: SettingsBundleKeys.AppVersionKey)
        let build: String = UIApplication.buildNumber ?? "0"
        UserDefaults.standard.set(build, forKey: SettingsBundleKeys.BuildVersionKey)
        let developmentTeam: String = "Rob In der Maur\nMarc Meewis"
        UserDefaults.standard.set(developmentTeam, forKey: SettingsBundleKeys.DevelopmentTeamKey)
    }
}
