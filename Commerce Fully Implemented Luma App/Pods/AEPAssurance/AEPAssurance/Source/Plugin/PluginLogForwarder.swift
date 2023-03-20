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

/// Plugin that acts on command to forward logs
///
/// The plugin gets invoked with Assurance command event having
/// - vendor  : "com.adobe.griffon.mobile"
/// - command type   : "logForwarding"
///
/// This plugin gets registered with `PluginHub` during the registration of Assurance extension.
/// Note: The debug logs through AEPServices goes to STDERR
/// Once the command to forward logs is received, this plugin interrupts the logs by creating a Pipe and replacing the STDERR file descriptor to pipe's file descriptor.
/// Plugin then reads the input to the pipe and forwards the logs to the connected assurance session.
class PluginLogForwarder: AssurancePlugin {
    weak var session: AssuranceSession?
    var vendor: String = AssuranceConstants.Vendor.MOBILE
    var commandType: String = AssuranceConstants.CommandType.LOG_FORWARDING

    var currentlyRunning: Bool = false
    private var logPipe = Pipe() /// consumes the log messages from STDERR
    private var consoleRedirectPipe = Pipe() /// outputs the log message back to STDERR
    private var logQueue: DispatchQueue = DispatchQueue(label: "com.adobe.assurance.log.forwarder")

    lazy var savedStdError: Int32 = dup(STDERR_FILENO)

    init() {
        /// Set up a read handler which fires when data is written into `logPipe`
        /// This handler intercepts the log, sends to assurance session and then redirects back to the console.
        logPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            let data = fileHandle.availableData
            if let logLine = String(data: data, encoding: .utf8) {
                self?.session?.sendEvent(AssuranceEvent(type: AssuranceConstants.EventType.LOG, payload: [AssuranceConstants.LogForwarding.LOG_LINE: AnyCodable.init(logLine)]))
            }

            /// writes log back to stderr
            self?.consoleRedirectPipe.fileHandleForWriting.write(data)
        }
    }

    /// this protocol method is called from `PluginHub` to handle log forwarding command
    func receiveEvent(_ event: AssuranceEvent) {
        // quick bail, if you cannot read the session instance
        guard self.session != nil else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to get the session instance. Assurance SDK is ignoring the command to start/stop forwarding logs.")
            return
        }

        guard let forwardingEnabled = event.commandLogForwardingEnable else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to read the enable key for log forwarding request. Ignoring the command to start/stop forwarding logs.")
            return
        }

        forwardingEnabled ? startForwarding() : stopForwarding()

    }

    /// protocol method is called from this Plugin is registered with `PluginHub`
    func onRegistered(_ session: AssuranceSession) {
        self.session = session
    }

    // no op - protocol methods
    func onSessionConnected() {}

    func onSessionDisconnectedWithCloseCode(_ closeCode: Int) {}

    func onSessionTerminated() {}

    func startForwarding() {
        logQueue.async {
            if self.currentlyRunning {
                Log.trace(label: AssuranceConstants.LOG_TAG, "Assurance SDK is already forwarding logs. Log forwarding start command is ignored.")
                return
            }

            self.currentlyRunning = true

            /// File Descriptors (FD) are non-negative integers (0, 1, 2, ...) that are associated with files that are opened.
            /// Standard Error STDERR  FileDescriptor value is always  2
            /// The dup() system call allocates a new file descriptor that refers
            /// to the same open file description as the descriptor provided parameter
            /// with the execution of the below code. A new lowest possible int value of fileDescription is created for savedStdError and it refers to stderr file descriptor.
            /// now we can use `savedStdError` and `STDERR_FILENO` interchangeably  Since the two file descriptors refer to
            /// the same open file description, they share file offset and file status flags
            self.savedStdError = dup(STDERR_FILENO)

            /// manual page for dup2 : https://man7.org/linux/man-pages/man2/dup.2.html
            /// syntax : int dup2(int oldfd, int newfd);
            dup2(STDERR_FILENO, self.consoleRedirectPipe.fileHandleForWriting.fileDescriptor)
            dup2(self.logPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        }
    }

    func stopForwarding() {
        logQueue.async {
            if !self.currentlyRunning {
                Log.trace(label: AssuranceConstants.LOG_TAG, "Assurance SDK is currently not forwarding logs. Log forwarding stop command is ignored.")
                return
            }

            /// the following dup2() makes STDERR_FILENO be the copy of  savedStdError descriptor, closing STDERR_FILENO first if necessary.
            dup2(self.savedStdError, STDERR_FILENO)
            close(self.savedStdError)
            self.currentlyRunning = false
        }
    }
}

private extension AssuranceEvent {
    var commandLogForwardingEnable: Bool? {
        return commandDetails?[AssuranceConstants.LogForwarding.ENABLE] as? Bool
    }
}
