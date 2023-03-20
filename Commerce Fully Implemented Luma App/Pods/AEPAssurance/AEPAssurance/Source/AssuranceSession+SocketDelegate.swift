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

extension AssuranceSession: SocketDelegate {
    ///
    /// Invoked when web socket is successfully connected.
    /// As per protocol with Assurance servers. Mobile Client after successful connection should send a clientInfo event containing the details of the connecting client.
    /// The server then validates and sends a startForwarding events on the reception of which Assurance should send further events to session.
    /// - Parameter socket - the socket instance
    ///
    func webSocketDidConnect(_ socket: SocketConnectable) {
        Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance session successfully connected.")
        self.sendClientInfoEvent()
    }

    ///
    /// Invoked when the socket is disconnected.
    /// - Parameters:
    ///     - socket: the socket instance.
    ///     - closeCode:An `Int` representing the reason for socket disconnection. Reference : https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
    ///     - reason: A `String` description for the reason for socket disconnection
    ///     - wasClean: A boolean representing if the connection has been terminated successfully. A false value represents the socket connection can be attempted to reconnected.
    func webSocketDidDisconnect(_ socket: SocketConnectable, _ closeCode: Int, _ reason: String, _ wasClean: Bool) {

        // Adding client log so user knows the reason for disconnection
        statusUI.addClientLog("Assurance Session disconnected : <br> &emsp; close code: \(closeCode) <br> &emsp; reason: \(reason) <br> &emsp; isClean : \(wasClean) ", visibility: .low)

        switch closeCode {

        // Normal Closure : Close code 4900
        // Happens when user disconnects hitting the disconnect button in Status UI.
        // notify plugin on normal closure
        case AssuranceConstants.SocketCloseCode.NORMAL_CLOSURE:
            Log.debug(label: AssuranceConstants.LOG_TAG, "Socket disconnected successfully with close code \(closeCode). Normal closure of websocket.")
            pinCodeScreen?.connectionFinished()
            statusUI.remove()
            pluginHub.notifyPluginsOnDisconnect(withCloseCode: closeCode)

        // ORG Mismatch : Close code 4900
        // Happens when there is an orgId mismatch between the griffon session and configured mobile SDK.
        // This is a non-retry error. Display the error back to user and close the connection.
        case AssuranceConstants.SocketCloseCode.ORG_MISMATCH:
            handleConnectionError(error: AssuranceConnectionError.orgIDMismatch, closeCode: closeCode)

        // Connection Limit : Close code 4901
        // Happens when the number of connections per session exceeds the limit
        // Configurable value and its default value is 200.
        // This is a non-retry error. Display the error back to user and close the connection.
        case AssuranceConstants.SocketCloseCode.CONNECTION_LIMIT:
            handleConnectionError(error: AssuranceConnectionError.connectionLimit, closeCode: closeCode)

        // Events Limit : Close code 4902
        // Happens when the clients exceeds the number of Griffon events that can be sent per minute.
        // Configurable value : default value is 10k events per minute
        // This is a non-retry error. Display the error back to user and close the connection.
        case AssuranceConstants.SocketCloseCode.EVENTS_LIMIT:
            handleConnectionError(error: AssuranceConnectionError.eventLimit, closeCode: closeCode)

        // Deleted Session : Close code 4903
        // Happens when the client connects to a deleted session.
        // This is a non-retry error. Display the error back to user and close the connection.
        case AssuranceConstants.SocketCloseCode.DELETED_SESSION:
            handleConnectionError(error: AssuranceConnectionError.deletedSession, closeCode: closeCode)

        // Events Limit : Close code 4400
        // This error is generically thrown if the client doesn't adhere to the protocol of the socket connection.
        // For example:
        // - If clientInfoEvent is not the first event to socket.
        // - If there are any missing parameters in the socket URL.
        case AssuranceConstants.SocketCloseCode.CLIENT_ERROR:
            handleConnectionError(error: AssuranceConnectionError.clientError, closeCode: closeCode)

        // For all other abnormal closures, display error back to UI and attempt to reconnect.
        default:
            Log.debug(label: AssuranceConstants.LOG_TAG, "Abnormal closure of webSocket. Reason - \(reason) and closeCode - \(closeCode)")
            pinCodeScreen?.connectionFailedWithError(AssuranceConnectionError.genericError)

            // do the reconnect logic only if session is already connected
            guard let _ = assuranceExtension.connectedWebSocketURL else {
                return
            }

            // immediately attempt to reconnect if the disconnect happens for the first time
            // then forth make an reconnect attempt every 5 seconds
            Log.debug(label: AssuranceConstants.LOG_TAG, "Attempting to reconnect....")
            let delayBeforeReconnect = isAttemptingToReconnect ? RECONNECT_TIMEOUT : 0

            // If the disconnect happens because of abnormal close code. And if we are attempting to reconnect for the first time then,
            // 1. Make an appropriate UI log.
            // 2. Change the button graphics to gray out.
            // 3. Notify plugins on disconnect with abnormal close code.
            // 4. Attempt to reconnect with appropriate time delay.
            if !isAttemptingToReconnect {
                isAttemptingToReconnect = true
                canStartForwarding = false // set this to false so that all the events are held up until client event is sent after successful reconnect
                statusUI.updateForSocketInActive()
                pluginHub.notifyPluginsOnDisconnect(withCloseCode: closeCode)
            }

            let delay = DispatchTimeInterval.seconds(delayBeforeReconnect)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.startSession()
            }
        }
    }

    ///
    /// Invoked when there is an error in socket connection.
    /// - Parameter socket - the socket instance
    func webSocketOnError(_ socket: SocketConnectable) {
        Log.debug(label: AssuranceConstants.LOG_TAG, "AssuranceSession: webSocketOnError is called. Error occurred during socket connection.")
    }

    ///
    /// Invoked when an `AssuranceEvent` is received from web socket connection.
    /// - Parameters:
    ///     - socket - the socket instance
    ///     - event - the `AssuranceEvent` received from socket
    func webSocket(_ socket: SocketConnectable, didReceiveEvent event: AssuranceEvent) {
        Log.trace(label: AssuranceConstants.LOG_TAG, "Received event from assurance session - \(event.description)")

        // add the incoming event to inboundQueue and process them
        inboundQueue.enqueue(newElement: event)
        inboundSource.add(data: 1)
    }

    /// Invoked when a socket connection state changes.
    /// - Parameters:
    ///     - socket - the socket instance
    ///     - state - the present socket state
    func webSocket(_ socket: SocketConnectable, didChangeState state: SocketState) {
        Log.debug(label: AssuranceConstants.LOG_TAG, "AssuranceSession: Socket state changed \(socket.socketState)")
        if state == .open {
            assuranceExtension.connectedWebSocketURL = socket.socketURL?.absoluteString
        }
    }

}
