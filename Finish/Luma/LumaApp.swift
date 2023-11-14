//
//  LumaApp.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import SwiftUI

@main
struct LumaApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
