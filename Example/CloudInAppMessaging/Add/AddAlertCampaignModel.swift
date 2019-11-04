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

import CloudInAppMessaging
import Foundation

final class AddAlertCampaignModel {
    let alertCampaign: CLMAlertCampaign

    // Show Language codes / Countries in English
    let locale = Locale(identifier: "en_US")

    lazy var languageCodes: [String] = {
        let allCodes = Locale.availableIdentifiers.compactMap {
            Locale.components(fromIdentifier: $0)[NSLocale.Key.languageCode.rawValue]
        }
        return Array(Set(allCodes)).sorted(by: <)
    }()

    private lazy var countryCodes: [String] = {
        let allCodes = Locale.availableIdentifiers
            .compactMap { Locale.components(fromIdentifier: $0)[NSLocale.Key.countryCode.rawValue] }
            .filter { $0.rangeOfCharacter(from: CharacterSet.letters) != nil } // filter countries only
        return Array(Set(allCodes)).sorted(by: <)
    }()

    init() {
        alertCampaign = CLMAlertCampaign()
        alertCampaign.defaultLangCode = "en"

        alertCampaign.buttonTitles = ["OK"]
        alertCampaign.buttonActionURLs = [CLMAlertCampaign.buttonURLNoAction]

        alertCampaign.trigger = .onForeground
    }

    func defaultLanguageModel() -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        if let defaultLangCode = alertCampaign.defaultLangCode,
            let selectedIndex = languageCodes.firstIndex(of: defaultLangCode) {
            selectedIndexes.insert(selectedIndex)
        }

        let model = LocaleSelectorModel(codes: languageCodes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }

    func countriesModel() -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        for country in alertCampaign.countries {
            guard let index = countryCodes.firstIndex(of: country) else {
                fatalError("Invalid country")
            }
            selectedIndexes.insert(index)
        }

        let model = LocaleSelectorModel(codes: countryCodes,
                                        localizeCode: {
                                            locale.localizedString(forRegionCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }

    func languagesModel() -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        for language in alertCampaign.languages {
            guard let index = languageCodes.firstIndex(of: language) else {
                fatalError("Invalid country")
            }
            selectedIndexes.insert(index)
        }

        let model = LocaleSelectorModel(codes: languageCodes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }

    // swiftlint:disable cyclomatic_complexity force_unwrapping

    func validate() -> String? {
        var messages = [String]()

        if alertCampaign.title == nil || alertCampaign.title!.isEmpty {
            messages.append("⚠️ 'Alert Title' is empty")
        }

        if alertCampaign.message == nil || alertCampaign.message!.isEmpty {
            messages.append("⚠️ 'Alert Message' is empty")
        }

        if alertCampaign.buttonTitles.isEmpty {
            messages.append("⚠️ 'No buttons defined'")
        }
        else {
            let uniqueTitles = Set(alertCampaign.buttonTitles)
            if uniqueTitles.count != alertCampaign.buttonTitles.count {
                messages.append("⚠️ One or more buttons are either empty or have the same titles")
            }

            let uniqueActions = Set(alertCampaign.buttonActionURLs)
            if uniqueActions.count != alertCampaign.buttonActionURLs.count {
                messages.append("⚠️ One or more buttons have the same actions")
            }
        }

        if alertCampaign.defaultLangCode == nil || alertCampaign.defaultLangCode!.isEmpty {
            messages.append("❌ 'Default Lang Code' is not set")
        }

        for translation in alertCampaign.translations {
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

            if !translationMessages.isEmpty {
                let shortID = translation.identifier.prefix(8)
                let message = "Translation <\(shortID)>:\n" + translationMessages.joined(separator: "\n")
                messages.append(message)
            }
        }

        if messages.isEmpty {
            return nil
        }

        return messages.joined(separator: "\n\n")
    }

    // swiftlint:enable cyclomatic_complexity force_unwrapping
}
