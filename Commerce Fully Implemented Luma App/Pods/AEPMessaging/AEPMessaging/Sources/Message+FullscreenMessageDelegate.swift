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
import Foundation
import UIKit

extension Message: FullscreenMessageDelegate {
    public func onShow(message _: FullscreenMessage) {}
    public func onShowFailure() {}

    /// Informs the parent of the calling `message` that it has been dismissed.
    ///
    /// - Parameter message: the `FullscreenMessage` being dismissed
    public func onDismiss(message: FullscreenMessage) {
        guard let message = message.parent else {
            return
        }

        message.dismiss()
    }

    /// Handles URL loading for links triggered from within the webview of the message.
    ///
    /// This method checks the `url` parameter to determine if it should be handled locally or by the webview in `message`.
    /// If the `url` has a scheme of "adbinapp", the URL will be handled locally for one or more purposes:
    /// - If the `url` host equals "dismiss", the webview will be removed from its superview.
    /// - If the `url` has a query parameter named "interaction", an interact event will be sent to experience edge
    ///   using the value provided for the "interaction" parameter.
    /// - If the `url` has a query parameter named "animate", the SDK will attempt to find a matching animation to be
    ///   used when dismissing the message. If no matching animation can be found, `MessageAnimation.none` will be used.
    /// - If the `url` has a query parameter named "link" and its value is a valid URL, the URL will be loaded in
    ///   by the operating system's default web browser (mobile Safari by default).
    ///
    /// - Parameters:
    ///   - message: the message attempting to load a URL
    ///   - url: the URL attempting to be loaded
    /// - Returns: false if the message's webview will handle the loading of the URL
    public func overrideUrlLoad(message fullscreenMessage: FullscreenMessage, url: String?) -> Bool {
        guard let urlString = url, let url = URL(string: urlString) else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Unable to load nil URL.")
            return true
        }

        if url.scheme == MessagingConstants.IAM.HTML.SCHEME {
            // handle request parameters
            let queryParams = url.queryParamMap()
            let message = fullscreenMessage.parent

            // handle optional tracking
            if let interaction = queryParams[MessagingConstants.IAM.HTML.INTERACTION], !interaction.isEmpty {
                message?.track(interaction, withEdgeEventType: .inappInteract)
            }

            // dismiss if requested
            if url.host == MessagingConstants.IAM.HTML.DISMISS {
                // check for an animation override
                if let animationOverride = queryParams[MessagingConstants.IAM.HTML.ANIMATE] {
                    message?.fullscreenMessage?.settings?.setDismissAnimation(MessageAnimation.fromString(animationOverride))
                }

                message?.dismiss(suppressAutoTrack: true)
            }

            // handle optional deep link
            if let link = queryParams[MessagingConstants.IAM.HTML.LINK], !link.isEmpty,
               let deeplinkUrl = URL(string: link.removingPercentEncoding ?? "") {
                UIApplication.shared.open(deeplinkUrl)
            }

            return false
        }

        return true
    }
}
