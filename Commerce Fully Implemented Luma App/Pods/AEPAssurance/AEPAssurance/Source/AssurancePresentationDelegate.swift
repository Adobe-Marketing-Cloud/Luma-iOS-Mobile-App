//
// Copyright 2022 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import Foundation

///
/// AssurancePresentationDelegate to delegate the Assurance Presentation flow for both Pin and QuickConnect
///
protocol AssurancePresentationDelegate {
    ///
    /// Returns true if there is an open socket connection
    ///
    var isConnected: Bool { get }
    
    ///
    /// Initializes the pin screen flow
    ///
    func initializePinScreenFlow()
    
    ///
    /// Tells the conforming delegate that the pin screen connect button has been clicked
    ///
    /// - Parameter: pin `String`
    ///
    func pinScreenConnectClicked(_ pin: String)
    
    ///
    /// Tells the conforming delegate that the pin screen cancel button has been clicked
    ///
    func pinScreenCancelClicked()
    
    ///
    /// Tells the conforming delegate that the disconned button has been clicked
    ///
    func disconnectClicked()
    
#if DEBUG
    ///
    /// Tells the conforming delegate to create a quick connect session with the given sessionDetails
    ///
    /// - Parameter: the sessionDetails `AssuranceSessionDetails` for the quick connect session
    ///
    func createQuickConnectSession(with sessionDetails: AssuranceSessionDetails)
    
    ///
    /// Tells the conforming delegate that an error occurred while going through the quick connect flow
    ///
    /// - Parameter: error `AssuranceConnectionError` the error which occurred
    ///
    func quickConnectError(error: AssuranceConnectionError)
    
    ///
    /// Tells the conforming delegate that the quick connect flow has been cancelled
    ///
    func quickConnectCancelled()
    
    ///
    /// Tells the conforming delegate to begin the quick connect handshake
    ///
    func quickConnectBegin()
#endif
}
