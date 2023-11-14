//
//  Logger.swift
//  Luma
//
//  Created by Rob In der Maur on 26/10/2022.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    
    /// Logs AEP Mobile SDK calls
    static let aepMobileSDK = Logger(subsystem: subsystem, category: "aepmobilesdk")
    
    /// Logs Direct API calls
    static let aepDirectAPI = Logger(subsystem: subsystem, category: "aepdirectapi")
    
    /// Logs notifications (push, locations, etc.) functionality
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
    
    /// Logs configuration functionality
    static let configuration = Logger(subsystem: subsystem, category: "configuration")
    
    /// Logs product details
    static let products = Logger(subsystem: subsystem, category: "products")
}
