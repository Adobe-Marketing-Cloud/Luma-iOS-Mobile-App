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
import Foundation

extension Event {
    // MARK: - Event Type/Source Detection

    /// A boolean value that determines whether event is a sharedState change event (Regular and XDM).
    var isSharedStateEvent: Bool {
        return type == EventType.hub && source == EventSource.sharedState
    }

    /// A boolean value that determines whether event is assurance request content event.
    var isAssuranceRequestContent: Bool {
        return type == AssuranceConstants.SDKEventType.ASSURANCE && source == EventSource.requestContent
    }

    /// A boolean value that determines whether event is a places request content event.
    var isPlacesRequestEvent: Bool {
        return type == EventType.places && source == EventSource.requestContent
    }

    /// A boolean value that determines whether event is a places response content event.
    var isPlacesResponseEvent: Bool {
        return type == EventType.places && source == EventSource.responseContent
    }

    /// A boolean value that determines whether event is Places nearby POI request.
    var isRequestNearByPOIEvent: Bool {
        return name == AssuranceConstants.Places.EventName.REQUEST_NEARBY_POI
    }

    /// A boolean value that determines whether event is Places request reset.
    var isRequestResetEvent: Bool {
        return name == AssuranceConstants.Places.EventName.REQUEST_RESET
    }

    /// A boolean value that determines whether event is Places region response event. Also called as region entry/exit events.
    var isResponseRegionEvent: Bool {
        return name == AssuranceConstants.Places.EventName.RESPONSE_REGION_EVENT
    }

    /// A boolean value that determines whether event is Places region nearby POI response event.
    var isResponseNearByEvent: Bool {
        return name == AssuranceConstants.Places.EventName.RESPONSE_NEARBY_POI_EVENT && responseID == nil
    }

    // MARK: - EventData values
    /// A string representing shared state owner for shared state change events.
    var sharedStateOwner: String? {
        return data?[AssuranceConstants.EventDataKey.SHARED_STATE_OWNER] as? String
    }

    /// A string representing POI count for places nearby POI request events.
    var poiCount: String {
        if let count = data?[AssuranceConstants.Places.EventDataKeys.COUNT] as? NSNumber {
            return count.stringValue
        }
        return "-"
    }

    /// A string representing latitude for places nearby POI request events.
    var latitude: String {
        if let lat = data?[AssuranceConstants.Places.EventDataKeys.LATITUDE] as? Double {
            return String(format: "%.6f", lat)
        }
        return "-"
    }

    /// A string representing longitude for places nearby POI request events.
    var longitude: String {
        if let lon = data?[AssuranceConstants.Places.EventDataKeys.LONGITUDE] as? Double {
            return String(format: "%.6f", lon)
        }
        return "-"
    }

    /// A string representing region type (Entry/Exit) for places region events.
    var regionEventType: String {
        return data?[AssuranceConstants.Places.EventDataKeys.REGION_EVENT_TYPE] as? String ?? "-"
    }

    /// A string representing region name for places region events.
    var regionName: String {
        let defaultValue = "-"
        guard let region = data?[AssuranceConstants.Places.EventDataKeys.TRIGGERING_REGION] as? [String: Any] else {
            return defaultValue
        }
        return region[AssuranceConstants.Places.EventDataKeys.REGION_NAME] as? String ?? defaultValue
    }

    /// An Array containing dictionary of nearby POI details for a places nearby POI response event.
    var nearByPOIs: [Any] {
        return data?[AssuranceConstants.Places.EventDataKeys.NEARBY_POI] as? Array ?? []
    }

}
