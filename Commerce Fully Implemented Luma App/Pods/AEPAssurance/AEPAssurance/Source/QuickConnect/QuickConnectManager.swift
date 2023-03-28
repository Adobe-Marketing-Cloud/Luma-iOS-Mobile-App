/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
import UIKit
import AEPServices

#if DEBUG
///
/// QuickConnectManager manages the QuickConnectService, and passes relevant updates from it to the AssurancePresentationDelegate
///
class QuickConnectManager {

    private let stateManager: AssuranceStateManager
    private let uiDelegate: AssurancePresentationDelegate
    private let quickConnectService = QuickConnectService()
    private let LOG_TAG = "QuickConnectManager"

    init(stateManager: AssuranceStateManager, uiDelegate: AssurancePresentationDelegate) {
        self.stateManager = stateManager
        self.uiDelegate = uiDelegate
    }

    func createDevice() {
        quickConnectService.shouldRetryGetDeviceStatus = true
        guard let orgID = stateManager.getURLEncodedOrgID() else {
            // log here
            Log.debug(label: LOG_TAG, "orgID is unexpectedly nil")
            return
        }
        quickConnectService.registerDevice(clientID: stateManager.clientID, orgID: orgID, completion: { error in
            guard let error = error else {
                self.checkDeviceStatus()
                return
            }
            self.uiDelegate.quickConnectError(error: error)
         })
     }
    
    private func checkDeviceStatus() {
        
        guard let orgID = stateManager.getURLEncodedOrgID() else {
            // log here
            Log.debug(label: LOG_TAG, "orgID is unexpectedly nil")
            return
        }
        quickConnectService.getDeviceStatus(clientID: stateManager.clientID, orgID: orgID, completion: { result in
            switch result {
            case .success((let sessionId, let token)):
                self.deleteDevice()
                let sessionDetails = AssuranceSessionDetails(sessionId: sessionId, clientId: self.stateManager.clientID, environment: AssuranceEnvironment.prod, token: String(token), orgID: orgID)
                self.uiDelegate.createQuickConnectSession(with: sessionDetails)
                break
            case .failure(let error):
                self.uiDelegate.quickConnectError(error: error)
                break
            }
            
        })
    }
    
    func deleteDevice() {
        guard let orgID = stateManager.getURLEncodedOrgID() else {
            Log.debug(label: LOG_TAG, "orgID is unexpectedly nil")
            return
        }
        
        quickConnectService.deleteDevice(clientID: stateManager.clientID, orgID: orgID, completion: { error in
            guard let error = error else {
                return
            }

            Log.debug(label: self.LOG_TAG, "Failed to delete device with error: \(error)")
        })

    }

    func cancelRetryGetDeviceStatus() {
        quickConnectService.shouldRetryGetDeviceStatus = false
    }
}
#endif
