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

/// Class that brings the capability to chunk the AssuranceEvent if in need to satisfy the socket size limit.
struct AssuranceEventChunker {

    /// The maximum size of data that an `AssuranceEvent` payload can hold after chunking
    ///
    /// AssuranceEvent Sizing:
    ///  The maximum size of an `AssuranceEvent` to get successfully delivered through the socket is 32KB.
    ///  AssuranceEvent consist of payload (Dictionary), type(String), vendor(String), metadata (Dictionary), timestamp(Long) and EventNumber (Integer)
    ///  For the AssuranceEvent to completely fit into the maximum allowed socket size, we safely assign
    ///    30KB for payload
    ///    2KB for other fields
    ///
    /// Accounting for escape string bloat factor:
    ///   After chunking the payload into multiple consumable data size, the chunk's are then recreated into corresponding `AssuranceEvent`s.
    /// During this process the chunked payload string is escaped and put inside the `chunkData` field of the resulting `AssuranceEvent`. This
    /// escaping of string further increases the size of the chunked Data. To accommodate for unknown bloating factor, the chunk size for each event is reduced to 15KB.
    ///
    /// Accounting for bloating due Base64 encoding
    /// The javascript websocket requires each message to be Base64 encoded before sending through the socket.
    /// Hence additionally a factor of 0.75 corresponds to size correction due to base64 Encoding of data before sending them over Websocket.
    let CHUNK_SIZE = (Int) ((15 * 1024) * 0.75) // ~11KB

    /// Chunks the given `AssuranceEvent` into multiple socket-consumable sized AssuranceEvents
    ///
    /// The payload field in the `AssuranceEvent` structure has the potential to bottleneck the size limit. Hence only the payload is chopped into multiple smaller chunks.
    /// Once the payload is chunked, then the chunked data is added in the payload of each AssuranceEvent under the key "chunkData".
    /// And chunked details are added to the metadata field of the Assurance Event. The chunk details are comprised of:
    ///   1. chunkId - Unique Id representing all the chunks of a single event.
    ///   2. chunkTotal - The total number of chunks to define the original event
    ///   3. chunkSequenceNumber - Integer Value representing the sequence of chunks. Used to identify the position of a specific chunk. Value ranges from 0 to (chunkTotal - 1)
    ///
    /// - Parameter event: An `AssuranceEvent` that needs to be sent over the socket
    /// - Returns: An array of chunked AssuranceEvents
    func chunk(_ event: AssuranceEvent) -> [AssuranceEvent] {
        let jsonData = event.jsonData

        // send the original event back if the size is within the socket limit
        if jsonData.count < AssuranceConstants.AssuranceEvent.SIZE_LIMIT {
            return [event]
        }
        var chunkedEvents: [AssuranceEvent] = []

        /// The payload is null and the event size exceeds MAX_EVENT_SIZE. This implies that
        /// the metadata is contributing to the event size increase. Metadata currently is data about
        /// chunks. It follows that metadata cannot be chunked. The current logic assumes that
        /// metadata is always within a sane limit (as it is being added internally) and any event
        /// with a large metadata cannot be handled currently. So, discard this event.
        /// When Assurance event is publicly instantiable, this assumption about metadata
        /// does not hold.
        /// If such a case arises, then the AssuranceEvent creation MUST handle restricting the size
        /// of metadata accordingly.
        guard let eventPayload = event.payload else {
            Log.warning(label: AssuranceConstants.LOG_TAG, "Discarding the Assurance Event that is demanding to be chunked without a payload. \(event.description)")
            return []
        }

        /// An unique ID representing this set of chunked events
        let chunkID = UUID().uuidString
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let payloadData = (try? encoder.encode(eventPayload)) ?? Data()
        let payloadSize = payloadData.count
        /// formula calculate total chunks (rounded up to the nearest integer)
        /// totalChunks = n / d + (n % d == 0 ? 0 : 1)
        ///  where:
        ///    n is the total payload size to be chunked
        ///    d is the size of each chunk
        let totalChunks = payloadSize / CHUNK_SIZE + ((payloadSize % CHUNK_SIZE) == 0 ? 0 : 1)
        for chunkCounter in 0..<totalChunks {
            var chunk: Data
            let chunkBase = chunkCounter * CHUNK_SIZE
            var diff = CHUNK_SIZE
            if chunkCounter == totalChunks - 1 {
                diff = payloadSize - chunkBase
            }
            let range: Range<Data.Index> = chunkBase..<(chunkBase + diff)
            chunk = payloadData.subdata(in: range)

            let decodedChunkString = String(decoding: chunk, as: UTF8.self)
            chunkedEvents.append(AssuranceEvent(type: event.type,
                                                payload: [AssuranceConstants.AssuranceEvent.PayloadKey.CHUNK_DATA: AnyCodable.init(decodedChunkString)],
                                                timestamp: event.timestamp ?? Date(),
                                                vendor: event.vendor,
                                                metadata: [ AssuranceConstants.AssuranceEvent.MetadataKey.CHUNK_ID: AnyCodable.init(chunkID),
                                                            AssuranceConstants.AssuranceEvent.MetadataKey.CHUNK_TOTAL: AnyCodable.init(totalChunks),
                                                            AssuranceConstants.AssuranceEvent.MetadataKey.CHUNK_SEQUENCE: AnyCodable.init(chunkCounter)]))
        }
        return chunkedEvents
    }
}
