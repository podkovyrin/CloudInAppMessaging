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

class AlertTranslationsModel {
    let alertCampaign: CLMAlertCampaign
    private(set) var translations: [CLMAlertTranslation]
    private let languageCodes: [String]
    private let locale: Locale

    init(alertCampaign: CLMAlertCampaign, languageCodes: [String], locale: Locale) {
        self.alertCampaign = alertCampaign
        self.languageCodes = languageCodes
        self.locale = locale
        translations = alertCampaign.translations
    }

    func addTranslation() {
        let translation = CLMAlertTranslation()
        translation.buttonTitles = Array(repeating: "", count: alertCampaign.buttonTitles.count)
        translations.append(translation)
    }

    func removeTranslation(_ translation: CLMAlertTranslation) {
        translations.removeAll {
            $0.identifier == translation.identifier
        }
    }

    func updateAlertCampaign() {
        alertCampaign.translations = translations
    }

    func languageModel(for translation: CLMAlertTranslation) -> LocaleSelectorModel {
        var selectedIndexes = Set<Int>()
        if let langCode = translation.langCode,
            let selectedIndex = languageCodes.firstIndex(of: langCode) {
            selectedIndexes.insert(selectedIndex)
        }

        let model = LocaleSelectorModel(codes: languageCodes,
                                        localizeCode: {
                                            locale.localizedString(forLanguageCode: $0) ?? ""
                                        },
                                        selectedIndexes: selectedIndexes)

        return model
    }
}
