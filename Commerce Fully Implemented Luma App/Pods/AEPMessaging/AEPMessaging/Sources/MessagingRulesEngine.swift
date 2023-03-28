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

import AEPCore
import AEPServices
import Foundation

/// Wrapper class around `LaunchRulesEngine` that provides a different implementation for loading rules
class MessagingRulesEngine {
    let rulesEngine: LaunchRulesEngine
    let runtime: ExtensionRuntime
    let cache: Cache
    var inMemoryPropositions: [PropositionPayload] = []
    var propositionInfo: [String: PropositionInfo] = [:]

    /// Initialize this class, creating a new rules engine with the provided name and runtime
    init(name: String, extensionRuntime: ExtensionRuntime) {
        runtime = extensionRuntime
        rulesEngine = LaunchRulesEngine(name: name,
                                        extensionRuntime: extensionRuntime)
        cache = Cache(name: MessagingConstants.Caches.CACHE_NAME)        
    }

    /// INTERNAL ONLY
    /// Initializer to provide a mock rules engine for testing
    init(extensionRuntime: ExtensionRuntime, rulesEngine: LaunchRulesEngine, cache: Cache) {
        runtime = extensionRuntime
        self.rulesEngine = rulesEngine
        self.cache = cache
    }

    /// if we have rules loaded, then we simply process the event.
    /// if rules are not yet loaded, add the event to the waitingEvents array to
    func process(event: Event) {
        _ = rulesEngine.process(event: event)
    }

    func loadPropositions(_ propositions: [PropositionPayload]?, clearExisting: Bool, persistChanges: Bool = true, expectedScope: String) {
                
        var rules: [LaunchRule] = []
        var tempPropInfo: [String: PropositionInfo] = [:]
        
        if let propositions = propositions {
            for proposition in propositions {
                guard expectedScope == proposition.propositionInfo.scope else {
                    Log.debug(label: MessagingConstants.LOG_TAG, "Ignoring proposition where scope (\(proposition.propositionInfo.scope)) does not match expected scope (\(expectedScope)).")
                    continue
                }
                                
                guard let ruleString = proposition.items.first?.data.content, !ruleString.isEmpty else {
                    Log.debug(label: MessagingConstants.LOG_TAG, "Skipping proposition with no in-app message content.")
                    continue
                }
                
                guard let rule = processRule(ruleString) else {
                    Log.debug(label: MessagingConstants.LOG_TAG, "Skipping proposition with malformed in-app message content.")
                    continue
                }
                
                // pre-fetch the assets for this message if there are any defined
                cacheRemoteAssetsFor(rule)
                
                // store reporting data for this payload for later use
                if let messageId = rule.first?.consequences.first?.id {
                    tempPropInfo[messageId] = proposition.propositionInfo
                }
                
                rules.append(contentsOf: rule)
            }
        }

        if clearExisting {
            inMemoryPropositions.removeAll()
            cachePropositions(nil)
            propositionInfo = tempPropInfo
            rulesEngine.replaceRules(with: rules)
            Log.debug(label: MessagingConstants.LOG_TAG, "Successfully loaded \(rules.count) message(s) into the rules engine for scope '\(expectedScope)'.")
        } else if !rules.isEmpty {
            propositionInfo.merge(tempPropInfo) { _, new in new }
            rulesEngine.addRules(rules)
            Log.debug(label: MessagingConstants.LOG_TAG, "Successfully added \(rules.count) message(s) into the rules engine for scope '\(expectedScope)'.")
        } else {
            Log.trace(label: MessagingConstants.LOG_TAG, "Ignoring request to load in-app messages for scope '\(expectedScope)'. The propositions parameter provided was empty.")
        }
        
        if persistChanges {
            addPropositionsToCache(propositions)
        } else {
            inMemoryPropositions.append(contentsOf: propositions ?? [])
        }
    }

    func processRule(_ rule: String) -> [LaunchRule]? {
        return JSONRulesParser.parse(rule.data(using: .utf8) ?? Data(), runtime: runtime)
    }

    func propositionInfoForMessageId(_ messageId: String) -> PropositionInfo? {
        return propositionInfo[messageId]
    }
        
    #if DEBUG
    /// For testing purposes only
    internal func propositionInfoCount() -> Int {
        return propositionInfo.count
    }
    
    /// For testing purposes only
    internal func inMemoryPropositionsCount() -> Int {
        return inMemoryPropositions.count
    }
    #endif
}
