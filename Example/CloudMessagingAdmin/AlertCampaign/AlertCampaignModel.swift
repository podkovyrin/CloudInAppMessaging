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

final class AlertCampaignModel {
    let alertCampaign: CLMAlertCampaign

    // Show Language codes / Countries in English
    let locale = Locale(identifier: "en_US")
    let localeCodes = LocaleCodes()

    private let service: AlertCampaignCloudKitService

    convenience init(service: AlertCampaignCloudKitService) {
        let alertCampaign = CLMAlertCampaign()
        alertCampaign.defaultLangCode = "en"

        alertCampaign.buttonTitles = ["OK"]
        alertCampaign.buttonActionURLs = [CLMAlertCampaign.ButtonURLNoAction]

        alertCampaign.trigger = .onForeground

        let localeCodes = LocaleCodes()
        alertCampaign.countries = localeCodes.countryCodes
        alertCampaign.languages = localeCodes.languageCodes

        self.init(alertCampaign: alertCampaign, service: service)
    }

    init(alertCampaign: CLMAlertCampaign, service: AlertCampaignCloudKitService) {
        self.alertCampaign = alertCampaign
        self.service = service
    }

    func defaultLanguageModel() -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        if let defaultLangCode = alertCampaign.defaultLangCode,
            let selectedIndex = localeCodes.languageCodes.firstIndex(of: defaultLangCode) {
            selectedIndexes.insert(selectedIndex)
        }

        let model = LocaleSelectorModel(codes: localeCodes.languageCodes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }

    func countriesModel() -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        for country in alertCampaign.countries {
            guard let index = localeCodes.countryCodes.firstIndex(of: country) else {
                fatalError("Invalid country")
            }
            selectedIndexes.insert(index)
        }

        let model = LocaleSelectorModel(codes: localeCodes.countryCodes,
                                        localizeCode: {
                                            locale.localizedString(forRegionCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }

    func languagesModel() -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        for language in alertCampaign.languages {
            guard let index = localeCodes.languageCodes.firstIndex(of: language) else {
                fatalError("Invalid country")
            }
            selectedIndexes.insert(index)
        }

        let model = LocaleSelectorModel(codes: localeCodes.languageCodes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }

    func save(_ alertCampaign: CLMAlertCampaign, completion: @escaping ([Error]) -> Void) {
        service.save(alertCampaign, completion: completion)
    }
}
