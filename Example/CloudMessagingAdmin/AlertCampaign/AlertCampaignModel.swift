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

        alertCampaign.bundleIdentifier = DefaultBundleIdentifier

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
        let selectedCodes = alertCampaign.defaultLangCode.flatMap { Set([$0]) } ?? Set()
        return LocaleSelectorModel(codes: localeCodes.languageCodes,
                                   localizeCode: {
                                       locale.localizedString(forLanguageCode: $0) ?? ""
                                   },
                                   selectedCodes: selectedCodes)
    }

    func countriesModel() -> LocaleSelectorModel {
        return LocaleSelectorModel(codes: localeCodes.countryCodes,
                                   localizeCode: {
                                       locale.localizedString(forRegionCode: $0) ?? ""
                                   },
                                   selectedCodes: Set(alertCampaign.countries),
                                   allowsMultiSelection: true)
    }

    func languagesModel() -> LocaleSelectorModel {
        return LocaleSelectorModel(codes: localeCodes.languageCodes,
                                   localizeCode: {
                                       locale.localizedString(forLanguageCode: $0) ?? ""
                                   },
                                   selectedCodes: Set(alertCampaign.languages),
                                   allowsMultiSelection: true)
    }

    func save(_ alertCampaign: CLMAlertCampaign, completion: @escaping ([Error]) -> Void) {
        service.save(alertCampaign, completion: completion)
    }
}
