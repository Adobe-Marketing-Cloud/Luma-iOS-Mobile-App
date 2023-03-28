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

import AEPServices
import Foundation

///
/// Represents the Assurance Session's Authorizing Presentation
///
class AssuranceAuthorizingPresentation {
    
    let sessionView: SessionAuthorizingUI
    
    init(authorizingView: SessionAuthorizingUI) {
        self.sessionView = authorizingView
    }
    
    /// Call this to show the UI elements that are required when a session is initialized.
    func show() {
        // invoke the pinpad screen and create a socketURL with the pincode and other essential parameters
        DispatchQueue.main.async {
            self.sessionView.show()
        }
    }
    
    func sessionConnecting() {
        self.sessionView.sessionConnecting()
    }
    
    func sessionConnected() {
        if sessionView.displayed {
            self.sessionView.sessionConnected()
        }
    }
    
    func sessionDisconnected() {
        sessionView.sessionDisconnected()
    }
    
    func sessionConnectionError(error: AssuranceConnectionError) {
        if sessionView.displayed == true {
            sessionView.sessionConnectionFailed(withError: error)
        } else {
            let errorView = ErrorView.init(AssuranceConnectionError.clientError)
            errorView.display()
        }
    }
}
