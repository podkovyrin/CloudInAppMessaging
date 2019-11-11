//
//  CloudInAppMessaging_Tests.swift
//  CloudInAppMessaging_Tests
//
//  Created by Andrew Podkovyrin on 11/1/19.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

import CloudInAppMessaging
import CloudKit
import XCTest

// swiftlint:disable force_cast

class CloudInAppMessagingTests: XCTestCase {
    func testValidation() {
        let alert = CLMAlertCampaign.testAlertCampaign()

        XCTAssertNil(alert.validate())
    }

    func testEquals() {
        let alert1 = CLMAlertCampaign.testAlertCampaign()
        let alert2 = CLMAlertCampaign.testAlertCampaign()

        XCTAssertNotEqual(alert1, alert2)

        XCTAssertEqual(alert1, alert1)
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
}
