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

extension CLMAlertCampaign {
    static func testAlertCampaign() -> CLMAlertCampaign {
        let alertCampaign = CLMAlertCampaign()
        alertCampaign.title = "Hello"
        alertCampaign.message = "World"

        alertCampaign.buttonTitles = ["OK"]
        alertCampaign.buttonActionURLs = [CLMAlertCampaign.ButtonURLNoAction]

        alertCampaign.defaultLangCode = "en"

        let translation = CLMAlertTranslation(alertCampaign: alertCampaign)
        translation.langCode = "ru"
        translation.title = "Привет"
        translation.message = "Мир"
        translation.buttonTitles = ["Окей"]
        alertCampaign.translations = [translation]

        alertCampaign.bundleIdentifier = DefaultBundleIdentifier
        alertCampaign.countries = ["US", "RU"]
        alertCampaign.languages = ["en", "ru"]
        alertCampaign.maxAppVersion = "3.14"
        alertCampaign.maxOSVersion = "13.99"
        alertCampaign.minAppVersion = "1.0"
        alertCampaign.minOSVersion = "11"

        alertCampaign.startDate = Date()
        alertCampaign.endDate = Date(timeIntervalSinceNow: 100_000)
        alertCampaign.trigger = .onForeground

        return alertCampaign
    }
}
