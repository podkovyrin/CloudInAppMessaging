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

class FetchFlowTests: XCTestCase {
    var settings = CLMSettings()
    var timeFetcher = MockTimeFetcher()
    var clientInfo = MockClientInfo()
    var stateKeeper: CLMStateKeeper!
    var memoryCache: CLMAlertMemoryCache!
    var userDefaults: UserDefaults!
    var fetchDelegate: MockFetchFlowDelegate!

    override func setUp() {
        super.setUp()

        settings.displayForegroundAlertMinInterval = 1
        settings.fetchMinInterval = 1

        userDefaults = UserDefaults(suiteName: "clm.fetchFlowTest")!
        stateKeeper = CLMStateKeeper(userDefaults: userDefaults, timeFetcher: timeFetcher)

        memoryCache = CLMAlertMemoryCache(stateKeeper: stateKeeper)

        fetchDelegate = MockFetchFlowDelegate()
    }

    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removePersistentDomain(forName: "clm.fetchFlowTest")
    }

    func testHappyPath() {
        let alert1 = alertCampaign()
        let alert2 = alertCampaign()

        let alertFetcher = MockAlertCampaignFetcher()
        alertFetcher.alerts = [alert1, alert2]

        settings.fetchMinInterval = 100
        timeFetcher.timeInterval = 200

        let fetchFlow = CLMFetchFlow(settings: settings,
                                     timeFetcher: timeFetcher,
                                     alertFetcher: alertFetcher,
                                     clientInfo: clientInfo,
                                     memoryCache: memoryCache,
                                     stateKeeper: stateKeeper,
                                     delegate: fetchDelegate)

        let expectation = XCTestExpectation()
        fetchDelegate.didFinishClosure = { flow, initialAppLaunch in
            XCTAssertEqual(fetchFlow, flow)
            XCTAssertTrue(initialAppLaunch)

            let fetchedAlerts = self.memoryCache.alerts
            XCTAssertEqual(alertFetcher.alerts, fetchedAlerts)

            XCTAssertEqual(self.stateKeeper.lastFetchTimeInterval,
                           self.timeFetcher.currentTimestamp(),
                           accuracy: 0.1)

            expectation.fulfill()
        }

        fetchFlow.checkAndFetch(forInitialAppLaunch: true)

        wait(for: [expectation], timeout: 0.1)
    }

    func testNoFetchDueToIntervalConstraint() {
        let alert1 = alertCampaign()
        let alert2 = alertCampaign()

        let alertFetcher = MockAlertCampaignFetcher()
        alertFetcher.alerts = [alert1, alert2]

        settings.fetchMinInterval = 100

        // record fetch at 100
        let lastFetch: TimeInterval = 100
        timeFetcher.timeInterval = lastFetch
        stateKeeper.recordFetch()

        // set current time
        timeFetcher.timeInterval = 110

        let fetchFlow = CLMFetchFlow(settings: settings,
                                     timeFetcher: timeFetcher,
                                     alertFetcher: alertFetcher,
                                     clientInfo: clientInfo,
                                     memoryCache: memoryCache,
                                     stateKeeper: stateKeeper,
                                     delegate: fetchDelegate)

        let expectation = XCTestExpectation()
        fetchDelegate.didFinishClosure = { flow, initialAppLaunch in
            XCTAssertEqual(fetchFlow, flow)

            XCTAssertTrue(self.memoryCache.alerts.isEmpty)

            XCTAssertEqual(self.stateKeeper.lastFetchTimeInterval,
                           lastFetch,
                           accuracy: 0.1)

            expectation.fulfill()
        }

        fetchFlow.checkAndFetch(forInitialAppLaunch: true)

        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchingNoAlerts() {
        let alertFetcher = MockAlertCampaignFetcher()

        let fetchFlow = CLMFetchFlow(settings: settings,
                                     timeFetcher: timeFetcher,
                                     alertFetcher: alertFetcher,
                                     clientInfo: clientInfo,
                                     memoryCache: memoryCache,
                                     stateKeeper: stateKeeper,
                                     delegate: fetchDelegate)

        let expectation = XCTestExpectation()
        fetchDelegate.didFinishClosure = { flow, initialAppLaunch in
            XCTAssertEqual(fetchFlow, flow)
            XCTAssertTrue(initialAppLaunch)

            XCTAssertNil(self.memoryCache.nextAlert(forTrigger: .onForeground))

            XCTAssertEqual(self.stateKeeper.lastFetchTimeInterval,
                           self.timeFetcher.currentTimestamp(),
                           accuracy: 0.1)

            expectation.fulfill()
        }

        fetchFlow.checkAndFetch(forInitialAppLaunch: true)

        wait(for: [expectation], timeout: 0.1)
    }

    func testNotMatchingMaxAppVersionsAlerts() {
        // MockClientInfo:
        // appVersion == "1.0"
        // osVersion == "13"

        let nonMatchingMaxAppVersions = ["0", "0.5.4", "0.9.9.9.9"]

        for version in nonMatchingMaxAppVersions {
            let alert = alwaysMatchingAlert()
            alert.maxAppVersion = version

            let alertFetcher = MockAlertCampaignFetcher()
            alertFetcher.alerts = [alert]

            performNonMatchingTest(alertFetcher: alertFetcher)
        }
    }

    func testNotMatchingMinAppVersionsAlerts() {
        let nonMatchingMinAppVersions = ["1.0.1", "1.5.4", "2"]

        for version in nonMatchingMinAppVersions {
            let alert = alwaysMatchingAlert()
            alert.minAppVersion = version

            let alertFetcher = MockAlertCampaignFetcher()
            alertFetcher.alerts = [alert]

            performNonMatchingTest(alertFetcher: alertFetcher)
        }
    }

    func testNotMatchingMaxOSVersionsAlerts() {
        let nonMatchingMaxOSVersions = ["12", "11.2", "12.9.9.9"]

        for version in nonMatchingMaxOSVersions {
            let alert = alwaysMatchingAlert()
            alert.maxOSVersion = version

            let alertFetcher = MockAlertCampaignFetcher()
            alertFetcher.alerts = [alert]

            performNonMatchingTest(alertFetcher: alertFetcher)
        }
    }

    func testNotMatchingMinOSVersionsAlerts() {
        let nonMatchingMinOSVersions = ["13.0.1", "13.2", "14.9.9.9"]

        for version in nonMatchingMinOSVersions {
            let alert = alwaysMatchingAlert()
            alert.minOSVersion = version

            let alertFetcher = MockAlertCampaignFetcher()
            alertFetcher.alerts = [alert]

            performNonMatchingTest(alertFetcher: alertFetcher)
        }
    }

    func testNotMatchingExpiredDateAlert() {
        let alert = alwaysMatchingAlert()
        alert.endDate = Date().addingTimeInterval(-100)

        let alertFetcher = MockAlertCampaignFetcher()
        alertFetcher.alerts = [alert]

        performNonMatchingTest(alertFetcher: alertFetcher)
    }

    func testNotMatchingAlreadyShownAlert() {
        let alert = alwaysMatchingAlert()

        stateKeeper.recordAlertImpression(alert)

        let alertFetcher = MockAlertCampaignFetcher()
        alertFetcher.alerts = [alert]

        performNonMatchingTest(alertFetcher: alertFetcher, cleanUpUserDefaults: false)
    }

    // MARK: Private

    private func alwaysMatchingAlert() -> CLMAlertCampaign {
        let alert = alertCampaign()
        // remove all triggering rules
        alert.endDate = nil
        alert.maxOSVersion = nil
        alert.maxAppVersion = nil
        alert.minOSVersion = nil
        alert.minAppVersion = nil

        return alert
    }

    private func performNonMatchingTest(alertFetcher: CLMAlertCampaignFetcher,
                                        cleanUpUserDefaults: Bool = true) {
        if cleanUpUserDefaults {
            UserDefaults.standard.removePersistentDomain(forName: "clm.fetchFlowTest")
        }

        timeFetcher.timeInterval = TimeInterval.random(in: 100 ... 200)

        let fetchFlow = CLMFetchFlow(settings: settings,
                                     timeFetcher: timeFetcher,
                                     alertFetcher: alertFetcher,
                                     clientInfo: clientInfo,
                                     memoryCache: memoryCache,
                                     stateKeeper: stateKeeper,
                                     delegate: fetchDelegate)

        let expectation = XCTestExpectation()
        fetchDelegate.didFinishClosure = { flow, initialAppLaunch in
            XCTAssertEqual(fetchFlow, flow)
            XCTAssertTrue(initialAppLaunch)

            XCTAssertTrue(self.memoryCache.alerts.isEmpty)

            // make sure fetch was completed
            XCTAssertEqual(self.stateKeeper.lastFetchTimeInterval,
                           self.timeFetcher.currentTimestamp(),
                           accuracy: 0.1)

            expectation.fulfill()
        }

        fetchFlow.checkAndFetch(forInitialAppLaunch: true)

        wait(for: [expectation], timeout: 0.1)
    }

    private func alertCampaign() -> CLMAlertCampaign {
        let alert = CLMAlertCampaign.testAlertCampaign()
        alert.translations = []
        return alert
    }

    private func translations() -> [CLMAlertTranslation] {
        let alert = CLMAlertCampaign.testAlertCampaign()
        return alert.translations
    }
}
