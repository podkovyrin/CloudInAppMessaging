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

final class AlertCampaignButton {
    var title: String
    var url: String

    init(title: String, url: String = CLMAlertCampaign.ButtonURLNoAction) {
        self.title = title
        self.url = url
    }
}

final class AlertCampaignButtonsModel {
    private(set) var buttons: [AlertCampaignButton]

    private let alertCampaign: CLMAlertCampaign

    init(alertCampaign: CLMAlertCampaign) {
        precondition(alertCampaign.isButtonsValid)

        self.alertCampaign = alertCampaign

        buttons = zip(alertCampaign.buttonTitles, alertCampaign.buttonActionURLs)
            .map { AlertCampaignButton(title: $0, url: $1) }
    }

    func addButton() {
        buttons.append(AlertCampaignButton(title: ""))

        for translation in alertCampaign.translations {
            translation.buttonTitles.append("")
        }
    }

    func removeButton(_ button: AlertCampaignButton) {
        buttons.removeAll(where: { $0 === button })

        for translation in alertCampaign.translations {
            translation.buttonTitles.removeLast()
        }
    }

    func updateAlertCampaign() {
        let titles = buttons.map { $0.title }
        let urls = buttons.map { button -> String in
            let url = button.url
            if url.isEmpty {
                return CLMAlertCampaign.ButtonURLNoAction
            }
            else {
                return url
            }
        }

        alertCampaign.buttonTitles = titles
        alertCampaign.buttonActionURLs = urls

        assert(alertCampaign.isButtonsValid, "Buttons titles and URLs are inconsistent")
    }
}
