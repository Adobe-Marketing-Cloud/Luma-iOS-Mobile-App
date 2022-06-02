/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPServices
import CoreLocation
import Foundation
import UIKit

enum AssuranceClientInfo {

    static let PLATFORM_NAME = "Canonical platform name"
    static let DEVICE_NAME = "Device name"
    static let OPERATING_SYSTEM = "Operating system"
    static let DEVICE_TYPE = "Device type"
    static let MODEL = "Model"
    static let SCREEN_SIZE = "Screen size"
    static let LOCATION_SERVICE_ENABLED = "Location service enabled"
    static let LOCATION_AUTHORIZATION_STATUS = "Location authorization status"
    static let LOW_POWER_BATTERY_ENABLED = "Low power mode enabled"
    static let BATTERY_LEVEL = "Battery level"

    static let PLATFORM_IOS = "iOS"

    /// Provides a `Dictionary` containing the client information required for the Assurance client event
    /// Client information includes
    /// 1. AppSetting Data  - Information from the info.plist
    /// 2. Device Information - Information like (Device Name, Device type, Battery level, OS Info, Location Auth status, etc.. )
    /// 3. Assurance extension's current version
    ///
    /// - Returns- A `Dictionary` containing the above mentioned data
    static func getData() -> [String: AnyCodable] {
        return [AssuranceConstants.ClientInfoKeys.VERSION: AnyCodable.init(AssuranceConstants.EXTENSION_VERSION),
                AssuranceConstants.ClientInfoKeys.TYPE: "connect",
                AssuranceConstants.ClientInfoKeys.APP_SETTINGS: AnyCodable.init(readAppSettingData()),
                AssuranceConstants.ClientInfoKeys.DEVICE_INFO: AnyCodable.init(readDeviceInfo())]
    }

    // MARK: - Private helper methods
    /// - Returns: A `Dictionary` containing the app's Info.plist data
    private static func readAppSettingData() -> NSDictionary {
        var appSettingsInDictionary: NSDictionary = [:]
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            appSettingsInDictionary = NSDictionary(contentsOfFile: path) ?? [:]
        }
        return appSettingsInDictionary
    }

    /// - Returns: A `Dictionary` with the required device information
    private static func readDeviceInfo() -> [String: Any] {
        let systemInfoService = ServiceProvider.shared.systemInfoService

        let screenSize = systemInfoService.getDisplayInformation()
        var deviceInfo: [String: Any] = [:]
        deviceInfo[PLATFORM_NAME] = PLATFORM_IOS
        deviceInfo[DEVICE_NAME] = UIDevice.current.name
        deviceInfo[OPERATING_SYSTEM] = ("\(systemInfoService.getOperatingSystemName()) \(systemInfoService.getOperatingSystemVersion())")
        deviceInfo[DEVICE_TYPE] = getDeviceType()
        deviceInfo[MODEL] = systemInfoService.getDeviceModelNumber()
        deviceInfo[SCREEN_SIZE] = "\(screenSize.width)x\(screenSize.height)"
        deviceInfo[LOCATION_SERVICE_ENABLED] = Bool(CLLocationManager.locationServicesEnabled())
        deviceInfo[LOCATION_AUTHORIZATION_STATUS] = getAuthStatusString(authStatus: CLLocationManager.authorizationStatus())
        deviceInfo[LOW_POWER_BATTERY_ENABLED] = ProcessInfo.processInfo.isLowPowerModeEnabled
        deviceInfo[BATTERY_LEVEL] = getBatteryLevel()
        return deviceInfo
    }

    /// Get the current battery level of the device.
    /// Battery level ranges from 0 (fully discharged) to 100 (fully charged).
    /// For simulator where the battery levels are not available -1 is returned.
    ///
    /// - Returns: An `Int` representing the battery level of the device
    private static func getBatteryLevel() -> Int {
        let batteryPercentage = Int(UIDevice.current.batteryLevel * 100)
        return (batteryPercentage) > 0 ? batteryPercentage : -1
    }

    /// - Returns: A `String` representing the device's location authorization status
    private static func getAuthStatusString(authStatus: CLAuthorizationStatus) -> String {
        switch authStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always"
        case .authorizedWhenInUse:
            return "When in use"
        @unknown default:
            return "Unknown"
        }
    }

    /// - Returns: A `String` representing the Apple's device type
    private static func getDeviceType() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .unspecified:
            return "Unspecified"
        case .phone:
            return "iPhone or iPod touch"
        case .pad:
            return "iPad"
        case .tv:
            return "Apple TV"
        case .carPlay:
            return "Apple Car Play"
        case .mac:
            return "Mac"
        @unknown default:
            return "Unspecified"
        }
    }

}
