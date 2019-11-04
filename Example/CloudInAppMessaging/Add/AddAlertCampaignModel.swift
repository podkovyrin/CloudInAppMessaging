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

    private let locale = Locale(identifier: "en_US")

    private lazy var languageCodes: [String] = {
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
}
