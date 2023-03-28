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

/// Helper methods for caching and loading previously retrieved in-app message definitions
extension MessagingRulesEngine {

    // MARK: - remote asset caching

    /// Caches any remote assets for RuleConsequence(s) found in provided rules.
    ///
    /// - Parameter rules: an array of `LaunchRule`s that may contain remote assets in their consequence(s)
    func cacheRemoteAssetsFor(_ rules: [LaunchRule]) {
        for rule in rules {
            for consequence in rule.consequences {
                if let assets = consequence.details[MessagingConstants.Event.Data.Key.IAM.REMOTE_ASSETS] as? [String] {
                    for asset in assets {
                        guard let url = URL(string: asset) else {
                            Log.debug(label: MessagingConstants.LOG_TAG, "Unable to cache message asset '\(asset)' for consequence id '\(consequence.id)'. Asset is not a valid URL.")
                            continue
                        }
                        let task = URLSession.shared.downloadTask(with: url) { imageUrl, _, _ in
                            if let image = imageUrl, let imageData = try? Data(contentsOf: image, options: .mappedIfSafe) {
                                let cacheEntry = CacheEntry(data: imageData,
                                                            expiry: CacheExpiry.seconds(MessagingConstants.THIRTY_DAYS_IN_SECONDS),
                                                            metadata: nil)
                                try? self.cache.set(key: asset, entry: cacheEntry)
                            }
                        }
                        task.resume()
                    }
                }
            }
        }
    }

    // MARK: - proposition caching

    /// Loads propositions from persistence into memory then hydrates the messaging rules engine
    func loadCachedPropositions(for expectedScope: String) {
        guard let cachedPropositions = cache.get(key: MessagingConstants.Caches.PROPOSITIONS) else {
            Log.trace(label: MessagingConstants.LOG_TAG, "Unable to load cached messages - cache file not found.")
            return
        }

        let decoder = JSONDecoder()
        guard let propositions: [PropositionPayload] = try? decoder.decode([PropositionPayload].self, from: cachedPropositions.data) else {
            return
        }

        Log.trace(label: MessagingConstants.LOG_TAG, "Loading in-app message definition from cache.")
        loadPropositions(propositions, clearExisting: false, persistChanges: false, expectedScope: expectedScope)
    }
    
    func addPropositionsToCache(_ propositions: [PropositionPayload]?) {
        guard let propositions = propositions, !propositions.isEmpty else {
            return
        }
        
        inMemoryPropositions.append(contentsOf: propositions)
        cachePropositions(inMemoryPropositions)
    }

    func cachePropositions(_ propositions: [PropositionPayload]?) {
        // remove cached propositions if param is nil or empty
        guard let propositions = propositions, !propositions.isEmpty else {
            do {
                try cache.remove(key: MessagingConstants.Caches.PROPOSITIONS)
                Log.trace(label: MessagingConstants.LOG_TAG, "In-app messaging cache has been deleted.")
            } catch let error as NSError {
                Log.trace(label: MessagingConstants.LOG_TAG, "Unable to remove in-app messaging cache: \(error).")
            }

            return
        }

        let encoder = JSONEncoder()
        guard let cacheData = try? encoder.encode(propositions) else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Error creating in-app messaging cache: unable to encode proposition.")
            return
        }
        let cacheEntry = CacheEntry(data: cacheData, expiry: .never, metadata: nil)
        do {
            try cache.set(key: MessagingConstants.Caches.PROPOSITIONS, entry: cacheEntry)
            Log.trace(label: MessagingConstants.LOG_TAG, "In-app messaging cache has been created.")
        } catch {
            Log.warning(label: MessagingConstants.LOG_TAG, "Error creating in-app messaging cache: \(error).")
        }
    }
}
