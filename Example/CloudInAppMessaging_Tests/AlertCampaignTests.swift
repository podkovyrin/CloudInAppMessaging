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

import CloudKit
import XCTest

// swiftlint:disable all

class AlertCampaignTests: XCTestCase {
    func testValidation() {
        let alert = CLMAlertCampaign.testAlertCampaign()

        XCTAssertNil(alert.validate())
    }

    func testEquals() {
        let alert1 = CLMAlertCampaign.testAlertCampaign()
        let alert2 = CLMAlertCampaign.testAlertCampaign()

        XCTAssertNotEqual(alert1, alert2)

        XCTAssertEqual(alert1, alert1)
        XCTAssertFalse(alert1.isEqual(123))
        XCTAssertFalse(alert1.isEqual(nil))
    }

    func testEquals2() {
        let updates: [(CLMAlertCampaign) -> Void] = [
            {
                $0.title = "Hola"
            },
            {
                $0.message = "Mundo"
            },
            {
                $0.buttonTitles = ["Okay"]
            },
            {
                $0.buttonActionURLs = ["https://test.com"]
            },
            {
                $0.defaultLangCode = "es"
            },
            {
                $0.bundleIdentifier = "com.new.bundle.id"
            },
            {
                $0.countries = ["ES", "EN"]
            },
            {
                $0.languages = ["es", "en"]
            },
            {
                $0.maxAppVersion = "4.14"
            },
            {
                $0.maxOSVersion = "12.99"
            },
            {
                $0.minAppVersion = "2.1"
            },
            {
                $0.minOSVersion = "11.5"
            },
            {
                $0.startDate = Date(timeIntervalSinceNow: 10000)
            },
            {
                $0.endDate = Date(timeIntervalSinceNow: 200_000)
            },
            {
                $0.trigger = .onAppLaunch
            },
        ]

        for update in updates {
            let alert = CLMAlertCampaign.testAlertCampaign()
            let original = CLMAlertCampaign(record: alert.record())
            original.translations = alert.translations

            update(alert)
            XCTAssertFalse(alert.isEqual(original))
        }
    }

    func testEqualsTranslations() {
        let alert = CLMAlertCampaign.testAlertCampaign()
        let translation1 = CLMAlertTranslation(alertCampaign: alert)
        let translation2 = CLMAlertTranslation(alertCampaign: alert)

        XCTAssertEqual(translation1, translation1)
        XCTAssertNotEqual(translation1, translation2)
        XCTAssertFalse(translation1.isEqual(123))
        XCTAssertFalse(translation1.isEqual(nil))
    }

    func testEqualsTranslations2() {
        let updates: [(CLMAlertTranslation) -> Void] = [
            {
                $0.langCode = "en"
            },
            {
                $0.title = "Hello"
            },
            {
                $0.message = "World"
            },
            {
                $0.buttonTitles = ["OK"]
            },
        ]

        for update in updates {
            let alert = CLMAlertCampaign.testAlertCampaign()
            let translation = alert.translations.first!
            let original = CLMAlertTranslation(record: translation.record())

            update(translation)
            XCTAssertFalse(translation.isEqual(original))
        }
    }

    func testDeserialization() {
        let alert = CLMAlertCampaign.testAlertCampaign()
        let record = alert.record()

        XCTAssertEqual(record["title"], alert.title)
        XCTAssertEqual(record["message"], alert.message)
        XCTAssertEqual(record["buttonActionURLs"], alert.buttonActionURLs)
        XCTAssertEqual(record["buttonTitles"], alert.buttonTitles)
        XCTAssertEqual(record["defaultLangCode"], alert.defaultLangCode)
        XCTAssertEqual(record["bundleIdentifier"], alert.bundleIdentifier)
        XCTAssertEqual(record["countries"], alert.countries)
        XCTAssertEqual(record["languages"], alert.languages)
        XCTAssertEqual(record["maxAppVersion"], alert.maxAppVersion)
        XCTAssertEqual(record["maxOSVersion"], alert.maxOSVersion)
        XCTAssertEqual(record["minAppVersion"], alert.minAppVersion)
        XCTAssertEqual(record["minOSVersion"], alert.minOSVersion)
        XCTAssertEqual(record["startDate"], alert.startDate)
        XCTAssertEqual(record["endDate"], alert.endDate)
        XCTAssertEqual(record["trigger"], alert.trigger?.rawValue)

        for translation in alert.translations {
            let translationRecord = translation.record()

            XCTAssertEqual(translationRecord["langCode"], translation.langCode)
            XCTAssertEqual(translationRecord["title"], translation.title)
            XCTAssertEqual(translationRecord["message"], translation.message)
            XCTAssertEqual(translationRecord["buttonTitles"], translation.buttonTitles)
            XCTAssertEqual((translationRecord[CLMAlertCampaign.ReferenceKey] as! CKRecord.Reference).recordID,
                           record.recordID)
        }
    }

    func testSerialization() {
        let alert1 = CLMAlertCampaign.testAlertCampaign()

        let alertRecord = alert1.record()
        let translationRecords = alert1.translations.map { $0.record() }

        let alert2 = CLMAlertCampaign(record: alertRecord)
        alert2.translations = translationRecords.map { CLMAlertTranslation(record: $0) }

        XCTAssertEqual(alert1, alert2)
    }

    func testAlertCampaignSchedulingChecks() {
        let alert = CLMAlertCampaign.testAlertCampaign()

        alert.startDate = nil
        XCTAssertTrue(alert.alertHasStarted())

        alert.endDate = nil
        XCTAssertFalse(alert.alertHasExpired())

        XCTAssertTrue(alert.alertDisplayed(onTrigger: .onForeground))

        alert.trigger = nil
        XCTAssertFalse(alert.alertDisplayed(onTrigger: .onAppLaunch))
    }

    func testHashFunctions() {
        let alert1 = CLMAlertCampaign.testAlertCampaign()
        let alert2 = CLMAlertCampaign(record: alert1.record())
        let translation1 = alert1.translations.first!
        let translation2 = CLMAlertTranslation(record: translation1.record())
        alert2.translations = [translation2]

        var alertDict = [alert1: "alert"]
        alertDict[alert2] = "new alert"
        XCTAssertTrue(alertDict.count == 1)

        var translationDict = [translation1: "translation"]
        translationDict[translation2] = "new translation"
        XCTAssertTrue(translationDict.count == 1)
    }
}
