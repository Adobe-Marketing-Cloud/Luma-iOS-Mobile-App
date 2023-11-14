//
//  SceneDelegate.swift
//  Luma
//
//  Created by Rob In der Maur on 01/06/2022.
//

import SwiftUI
import AEPAssurance
import AEPCore

/// to handle callbacks just for the current scene
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @Environment(\.openURL) var openURL
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool ) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        openURL(url, completion: completionHandler)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Called when the app in background is opened with a deep link.
        if let deepLinkURL = URLContexts.first?.url {
            // Start the Assurance session
            
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // When in foreground start lifecycle data collection
        
    }
    
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // When in background pause lifecycle data collection
        
    }
}

