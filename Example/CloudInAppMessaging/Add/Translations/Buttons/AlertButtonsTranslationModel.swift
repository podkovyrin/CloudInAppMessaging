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

class AlertCampaignButtonTranslation {
    var title: String
    var originalTitle: String

    init(title: String, originalTitle: String) {
        self.title = title
        self.originalTitle = originalTitle
    }
}

class AlertButtonsTranslationModel {
    private(set) var buttons: [AlertCampaignButtonTranslation]
    let alertCampaign: CLMAlertCampaign

    private let translation: CLMAlertTranslation

    init(alertCampaign: CLMAlertCampaign, translation: CLMAlertTranslation) {
        self.alertCampaign = alertCampaign
        self.translation = translation

        var buttons = [AlertCampaignButtonTranslation]()
        for (title, originalTitle) in zip(translation.buttonTitles, alertCampaign.buttonTitles) {
            let buttonTranslation = AlertCampaignButtonTranslation(title: title, originalTitle: originalTitle)
            buttons.append(buttonTranslation)
        }
        self.buttons = buttons
    }

    func updateTranslation() {
        translation.buttonTitles = buttons.map { $0.title }
    }
}
