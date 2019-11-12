//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

// This file is shared among the Admin App and Tests target
// For the Test target CloudInAppMessaging code imported directly
#if !TEST
    import CloudInAppMessaging
#endif // TEST

import Foundation

extension CLMAlertCampaign {
    // swiftlint:disable cyclomatic_complexity force_unwrapping

    func validate() -> String? {
        let hasEmptyButtonTitles: ([String]) -> Bool = { buttonTitles in
            for buttonTitle in buttonTitles where buttonTitle.isEmpty {
                return true
            }

            return false
        }

        var messages = [String]()

        if title == nil || title!.isEmpty {
            messages.append("⚠️ 'Alert Title' is empty")
        }

        if message == nil || message!.isEmpty {
            messages.append("⚠️ 'Alert Message' is empty")
        }

        if buttonTitles.isEmpty {
            messages.append("⚠️ 'No buttons defined'")
        }
        else {
            let uniqueTitles = Set(buttonTitles)
            if uniqueTitles.count != buttonTitles.count {
                messages.append("⚠️ One or more buttons are either empty or have the same titles")
            }
            else if hasEmptyButtonTitles(buttonTitles) {
                messages.append("⚠️ One or more buttons have empty titles")
            }

            let uniqueActions = Set(buttonActionURLs)
            if uniqueActions.count != buttonActionURLs.count {
                messages.append("⚠️ One or more buttons have the same actions")
            }
        }

        if defaultLangCode == nil || defaultLangCode!.isEmpty {
            messages.append("❌ 'Default Lang Code' is not set")
        }

        if bundleIdentifier == nil || bundleIdentifier!.isEmpty {
            messages.append("❌ 'Bundle ID' is not set")
        }

        if countries.isEmpty {
            messages.append("❌ 'Countries' is not specified")
        }

        if languages.isEmpty {
            messages.append("❌ 'Languages' is not specified")
        }

        for translation in translations {
            var translationMessages = [String]()

            if translation.langCode == nil || translation.langCode!.isEmpty {
                translationMessages.append("❌ 'Language' is not set")
            }

            if translation.title == nil || translation.title!.isEmpty {
                translationMessages.append("⚠️ 'Alert Title' is empty")
            }

            if translation.message == nil || translation.message!.isEmpty {
                translationMessages.append("⚠️ 'Alert Message' is empty")
            }

            let uniqueButtons = Set(translation.buttonTitles)
            if uniqueButtons.count != translation.buttonTitles.count {
                translationMessages.append("⚠️ One or more buttons are either empty or have the same titles")
            }
            else if hasEmptyButtonTitles(translation.buttonTitles) {
                translationMessages.append("⚠️ One or more buttons have empty titles")
            }

            if !translationMessages.isEmpty {
                let shortID = translation.identifier.prefix(8)
                let message = "Translation <\(shortID)>:\n" + translationMessages.joined(separator: "\n")
                messages.append(message)
            }
        }

        if let endDate = endDate {
            let now = Date()
            if endDate < now {
                messages.append("❌ 'End Date' is invalid")
            }

            if let startDate = startDate, endDate < startDate {
                messages.append("❌ 'End Date' should be greater than 'Start Date'")
            }
        }

        if trigger == nil || trigger!.rawValue.isEmpty {
            messages.append("❌ 'Trigger' is not defined")
        }

        if messages.isEmpty {
            return nil
        }

        return messages.joined(separator: "\n\n")
    }

    // swiftlint:enable cyclomatic_complexity force_unwrapping
}
