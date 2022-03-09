/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import AEPServices
import Foundation

/// Defines the public interface for the `UserProfile` extension
@objc public extension UserProfile {
    ///  Called by the public API to update user attributes.
    ///  If the attribute does not exist, it will be created.
    ///  If the attribute already exists, then the value will be updated.
    ///
    /// - Parameter attributeDict: the dictionary containing attribute key-value pairs
    static func updateUserAttributes(attributeDict: [String: Any]) {
        guard !attributeDict.isEmpty else {
            Log.trace(label: LOG_TAG, "updateUserAttributes - dictionary was empty, no event was dispatched")
            return
        }

        let eventData = [UserProfileConstants.UserProfile.EventDataKeys.UPDATE_DATA: attributeDict]
        let event = Event(name: UserProfileConstants.UserProfile.EVENT_NAME_UPDATE_USER_PROFILE, type: EventType.userProfile, source: EventSource.requestProfile, data: eventData)
        MobileCore.dispatch(event: event)
    }

    /// Called by the public API to remove the given user attributes.
    /// If the attribute does not exist, then user profile module ignores the event. No shared state or user profile response event is dispatched
    /// If the attribute exists, then the User Attribute will be removed, shared state is updated and user profile response event is dispatched
    /// - Parameter attributeNames: attribute keys/names which have to be removed.
    static func removeUserAttributes(attributeNames: [String]) {
        guard !attributeNames.isEmpty else {
            Log.trace(label: LOG_TAG, "removeUserAttributes - no name provided, no event was dispatched")
            return
        }
        let eventData = [UserProfileConstants.UserProfile.EventDataKeys.REMOVE_DATA: attributeNames]
        let event = Event(name: UserProfileConstants.UserProfile.EVENT_NAME_REMOVE_USER_PROFILE, type: EventType.userProfile, source: EventSource.requestReset, data: eventData)
        MobileCore.dispatch(event: event)
    }

    /// Called by the public API to get the user attributes
    /// - Parameters:
    ///   - attributeNames: Attribute keys/names which will be used to retrieve user attributes
    ///   - completion: the callback `closure` which will be called with user attributes
    static func getUserAttributes(attributeNames: [String], completion: @escaping ([String: Any]?, AEPError) -> Void) {
        guard !attributeNames.isEmpty else {
            Log.trace(label: LOG_TAG, "getUserAttributes - no name provided, no event was dispatched")
            completion(nil, .none)
            return
        }
        let eventData = [UserProfileConstants.UserProfile.EventDataKeys.GET_DATA_ATTRIBUTES: attributeNames]
        let event = Event(name: UserProfileConstants.UserProfile.EVENT_NAME_GET_USER_PROFILE, type: EventType.userProfile, source: EventSource.requestProfile, data: eventData)
        MobileCore.dispatch(event: event) { responseEvent in
            guard let responseEvent = responseEvent else {
                completion(nil, .callbackTimeout)
                return
            }
            guard !responseEvent.isErrorResponseEvent else {
                completion(nil, .unexpected)
                return
            }
            let attributes = responseEvent.data?[UserProfileConstants.UserProfile.EventDataKeys.GET_DATA_ATTRIBUTES] as? [String: Any]
            completion(attributes, .none)
        }
    }
}
