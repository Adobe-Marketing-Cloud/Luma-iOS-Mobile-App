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

extension AssuranceSession {

    ///
    /// Sends a clientInfo event to the connection session.
    ///
    func sendClientInfoEvent() {
        Log.debug(label: AssuranceConstants.LOG_TAG, "Sending client info event to Assurance")
        let clientEvent = AssuranceEvent.init(type: AssuranceConstants.EventType.CLIENT, payload: AssuranceClientInfo.getData())
        self.socket.sendEvent(clientEvent)
    }

    ///
    /// Handles the queuing and forwarding of outbound session events.
    ///
    func handleOutBoundEvents() {
        outboundSource.setEventHandler(handler: {
            if self.socket.socketState != .open {
                Log.trace(label: AssuranceConstants.LOG_TAG, "Assurance extension queuing event before socket connection is established.")
                return
            }

            if !self.canStartForwarding {
                Log.trace(label: AssuranceConstants.LOG_TAG, "Assurance Extension hasn't received startForwarding control event to start sending the queued events.")
                return
            }

            while self.outboundQueue.size() > 0 {
                let event = self.outboundQueue.dequeue()
                if let event = event {
                    self.socket.sendEvent(event)
                }
            }
        })
        outboundSource.resume()
    }

    ///
    /// Handles the queuing and receiving of inbound Assurance session events.
    ///
    func handleInBoundEvents() {
        inboundSource.setEventHandler(handler: {
            while self.inboundQueue.size() > 0 {
                guard let event = self.inboundQueue.dequeue() else {
                    Log.trace(label: AssuranceConstants.LOG_TAG, "Unable to read a valid event from inbound event queue. Ignoring to process the Inbound event from the Assurance Session.")
                    return
                }

                guard let controlType = event.commandType else {
                    Log.debug(label: AssuranceConstants.LOG_TAG, "A non control event is received from assurance session. Ignoring to process event - \(event.description)")
                    return
                }

                if AssuranceConstants.CommandType.START_EVENT_FORWARDING == controlType {
                    self.canStartForwarding = true
                    // On reception of the startForwarding event
                    // 1. Remove the WebView UI and display the floating button
                    // 2. Share the Assurance shared state
                    // 3. Notify the client plugins on successful connection
                    self.pinCodeScreen?.connectionSucceeded()
                    self.statusUI.display()
                    self.statusUI.updateForSocketConnected()
                    self.pluginHub.notifyPluginsOnConnect()
                    self.outboundSource.add(data: 1)

                    // If the initial SDK events were cleared because of Assurance shutting down after 5 second timeout
                    // then populate the griffon session with all the available shared state details (Both XDM and Regular)
                    if self.didClearBootEvent {
                        let stateEvents = self.assuranceExtension.getAllExtensionStateData()
                        Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance extension cleared the initial queued events. Sharing the shared state data of \(stateEvents.count) registered extensions.")
                        for eachStateEvent in stateEvents {
                            self.outboundQueue.enqueue(newElement: eachStateEvent)
                        }
                        self.outboundSource.add(data: 1)
                    }
                    return
                }

                self.pluginHub.notifyPluginsOfEvent(event)
            }
        })
        inboundSource.resume()
    }

}
