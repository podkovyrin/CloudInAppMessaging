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

import XCTest

// swiftlint:disable all

class AlertCampaignPresentingTests: XCTestCase {
    func testAlertDataSource() {
        let alert = alertCampaign()

        // DataSource as alert itself

        XCTAssertEqual(alert.defaultLangCode, "en")
        var dataSource = alert.dataSource(forPreferredLanguages: ["en"])
        XCTAssertTrue(alert === dataSource)

        // DataSource as existing translation

        let translation = alert.translations.first!

        XCTAssertEqual(translation.langCode, "ru")
        dataSource = alert.dataSource(forPreferredLanguages: ["ru"])
        XCTAssertNotEqual(translation.identifier, (dataSource as! CLMAlertTranslation).identifier)
        XCTAssertEqual(translation.langCode, (dataSource as! CLMAlertTranslation).langCode)
        XCTAssertEqual(translation.title, dataSource.title)
        XCTAssertEqual(translation.message, dataSource.message)
        XCTAssertEqual(translation.buttonTitles, dataSource.buttonTitles)

        // DataSource for unknown language

        dataSource = alert.dataSource(forPreferredLanguages: ["fr"])
        XCTAssertTrue(alert === dataSource)
    }

    func testFallbackTranslations() {
        let alert = alertCampaign()

        let translation = CLMAlertTranslation(alertCampaign: alert)
        translation.langCode = "fr"
        translation.buttonTitles = [""]

        var translations = alert.translations
        translations.append(translation)
        alert.translations = translations

        let dataSource = alert.dataSource(forPreferredLanguages: ["fr"])
        XCTAssertNotEqual(alert.identifier, (dataSource as! CLMAlertTranslation).identifier)
        XCTAssertEqual((dataSource as! CLMAlertTranslation).langCode, "fr")
        XCTAssertEqual(alert.title, dataSource.title)
        XCTAssertEqual(alert.message, dataSource.message)
        XCTAssertEqual(alert.buttonTitles, dataSource.buttonTitles)
    }

    private func alertCampaign() -> CLMAlertCampaign {
        let alert = CLMAlertCampaign.testAlertCampaign()
        return alert
    }
}
