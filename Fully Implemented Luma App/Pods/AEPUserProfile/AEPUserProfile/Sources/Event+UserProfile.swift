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
import Foundation

extension Event {
    // MARK: - UserProfile Request

    var isUpdateAttributesEvent: Bool {
        data?[UserProfileConstants.UserProfile.EventDataKeys.UPDATE_DATA] != nil
    }

    var isGetAttributesEvent: Bool {
        data?[UserProfileConstants.UserProfile.EventDataKeys.GET_DATA_ATTRIBUTES] != nil
    }

    // MARK: - RulesEngine Response

    var isRulesConsequenceEvent: Bool {
        data?[UserProfileConstants.RulesEngine.EventDataKeys.TRIGGERED_CONSEQUENCE] != nil
    }

    // MARK: - Consequence Data

    private var consequence: [String: Any]? {
        data?[UserProfileConstants.RulesEngine.EventDataKeys.TRIGGERED_CONSEQUENCE] as? [String: Any]
    }

    var consequenceType: String? {
        consequence?[UserProfileConstants.RulesEngine.EventDataKeys.TYPE] as? String
    }

    private var detail: [String: Any]? {
        consequence?[UserProfileConstants.RulesEngine.EventDataKeys.DETAIL] as? [String: Any]
    }

    var detailKey: String? {
        detail?[UserProfileConstants.RulesEngine.EventDataKeys.DETAIL_KEY] as? String
    }

    var detailValue: String? {
        detail?[UserProfileConstants.RulesEngine.EventDataKeys.DETAIL_VALUE] as? String
    }

    var detailOperation: String? {
        detail?[UserProfileConstants.RulesEngine.EventDataKeys.DETAIL_OPERATION] as? String
    }

    // MARK: - Error Response Data

    var isErrorResponseEvent: Bool {
        data?[UserProfileConstants.UserProfile.EventDataKeys.ERROR_RESPONSE] != nil
    }

    var errorMessage: String? {
        data?[UserProfileConstants.UserProfile.EventDataKeys.ERROR_MESSAGE] as? String
    }
}
