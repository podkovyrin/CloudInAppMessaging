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

class AddAlertCampaignModel {
    let alertCampaign: CLMAlertCampaign

    private let locale = Locale(identifier: "en_US")
    private lazy var languageCodes: [String] = {
        let allCodes = Locale.availableIdentifiers.compactMap {
            Locale.components(fromIdentifier: $0)[NSLocale.Key.languageCode.rawValue]
        }
        return Array(Set(allCodes)).sorted(by: <)
    }()

    private lazy var countryCodes: [String] = {
        let allCodes = Locale.availableIdentifiers.compactMap {
            Locale.components(fromIdentifier: $0)[NSLocale.Key.countryCode.rawValue]
        }
        return Array(Set(allCodes)).sorted(by: <)
    }()

    lazy var languageCodes1: LocaleSelectorModel = {
        let allCodes = Locale.availableIdentifiers.compactMap {
            Locale.components(fromIdentifier: $0)[NSLocale.Key.languageCode.rawValue]
        }
        let codes = Array(Set(allCodes)).sorted(by: <)
        let model = LocaleSelectorModel(codes: codes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndex: nil)

        return model
    }()

    lazy var countryCodes1: LocaleSelectorModel = {
        let allCodes = Locale.availableIdentifiers.compactMap {
            Locale.components(fromIdentifier: $0)[NSLocale.Key.countryCode.rawValue]
        }
        let codes = Array(Set(allCodes)).sorted(by: <)
        let model = LocaleSelectorModel(codes: codes,
                                        localizeCode: {
                                            locale.localizedString(forRegionCode: $0) ?? ""
                                        },
                                        selectedIndex: nil)

        return model
    }()

    init() {
        alertCampaign = CLMAlertCampaign()
        alertCampaign.defaultLangCode = "en"

        alertCampaign.buttonTitles = ["OK"]
        alertCampaign.buttonActionURLs = [CLMAlertCampaign.buttonURLNoAction]

        alertCampaign.trigger = .onForeground
    }

    func defaultLanguageModel() -> LocaleSelectorModel {
        var selectedIndex: Int?
        if let defaultLangCode = alertCampaign.defaultLangCode {
            selectedIndex = languageCodes.firstIndex(of: defaultLangCode)
        }
        let model = LocaleSelectorModel(codes: languageCodes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndex: selectedIndex)

        return model
    }
}
