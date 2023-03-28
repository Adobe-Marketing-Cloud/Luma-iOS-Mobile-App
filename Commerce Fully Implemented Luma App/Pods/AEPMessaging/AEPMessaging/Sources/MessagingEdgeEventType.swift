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

import Foundation

/// Provides mapping to XDM EventType strings needed for Experience Event requests
@objc(AEPMessagingEdgeEventType)
public enum MessagingEdgeEventType: Int {
    case inappDismiss = 0
    case inappInteract = 1
    case inappTrigger = 2
    case inappDisplay = 3
    case pushApplicationOpened = 4
    case pushCustomAction = 5

    public func toString() -> String {
        switch self {
        case .inappDismiss:
            return MessagingConstants.XDM.IAM.EventType.DISMISS
        case .inappTrigger:
            return MessagingConstants.XDM.IAM.EventType.TRIGGER
        case .inappInteract:
            return MessagingConstants.XDM.IAM.EventType.INTERACT
        case .inappDisplay:
            return MessagingConstants.XDM.IAM.EventType.DISPLAY
        case .pushCustomAction:
            return MessagingConstants.XDM.Push.EventType.CUSTOM_ACTION
        case .pushApplicationOpened:
            return MessagingConstants.XDM.Push.EventType.APPLICATION_OPENED
        }
    }
}

extension MessagingEdgeEventType {
    /// Used to generate `propositionEventType` payload in outgoing proposition interaction events
    var propositionEventType: String {
        switch self {
        case .inappDismiss:
            return MessagingConstants.XDM.IAM.PropositionEventType.DISMISS
        case .inappInteract:
            return MessagingConstants.XDM.IAM.PropositionEventType.INTERACT
        case .inappTrigger:
            return MessagingConstants.XDM.IAM.PropositionEventType.TRIGGER
        case .inappDisplay:
            return MessagingConstants.XDM.IAM.PropositionEventType.DISPLAY
        case .pushApplicationOpened, .pushCustomAction:
            return ""
        default:
            return ""
        }
    }
}
