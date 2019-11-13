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

class DisplayExecutorTests: XCTestCase {
    var settings = CLMSettings()
    var timeFetcher = MockTimeFetcher()
    var clientInfo = MockClientInfo()
    var stateKeeper: CLMStateKeeper!
    var memoryCache: CLMAlertMemoryCache!
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        settings.displayForegroundAlertMinInterval = 1
        settings.fetchMinInterval = 1

        userDefaults = UserDefaults(suiteName: "clm.displayExecutorTest")!
        stateKeeper = CLMStateKeeper(userDefaults: userDefaults, timeFetcher: timeFetcher)

        memoryCache = CLMAlertMemoryCache(stateKeeper: stateKeeper)
    }

    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removePersistentDomain(forName: "clm.displayExecutorTest")
    }

    func testDisplayingOnAppLaunch() {
        performDisplayingTest(trigger: .onAppLaunch)
    }

    func testDisplayingOnForeground() {
        performDisplayingTest(trigger: .onForeground)
    }

    func testDisplayIsNotAllowed() {
        timeFetcher.timeInterval = 100
        settings.displayForegroundAlertMinInterval = 50
        stateKeeper.recordAlertImpression(alertCampaign())

        let presentingAlert = alertCampaign()
        memoryCache.setAlertsData([presentingAlert])

        let expectation = XCTestExpectation()
        expectation.isInverted = true

        let presenter = MockAlertPresenter()
        presenter.didFinishPresentingAlertClosure = { _, _ in
            expectation.fulfill()
        }

        let executor = CLMDisplayExecutor(settings: settings,
                                          timeFetcher: timeFetcher,
                                          clientInfo: clientInfo,
                                          memoryCache: memoryCache,
                                          stateKeeper: stateKeeper)
        executor.alertPresenter = presenter

        executor.checkAndDisplayNextAppForegroundAlert()

        wait(for: [expectation], timeout: 1.0)
    }

    func testNotDisplayingAsSupressed() {
        let presentingAlert = alertCampaign()
        memoryCache.setAlertsData([presentingAlert])

        let expectation = XCTestExpectation()
        expectation.isInverted = true

        let presenter = MockAlertPresenter()
        presenter.didFinishPresentingAlertClosure = { _, _ in
            expectation.fulfill()
        }

        let executor = CLMDisplayExecutor(settings: settings,
                                          timeFetcher: timeFetcher,
                                          clientInfo: clientInfo,
                                          memoryCache: memoryCache,
                                          stateKeeper: stateKeeper)
        executor.alertPresenter = presenter

        executor.setMessageDisplaySuppressed(true)

        executor.checkAndDisplayNextAppForegroundAlert()

        wait(for: [expectation], timeout: 1.0)
    }

    func testNotDisplayingAsAlreadyDisplaying() {
        timeFetcher.timeInterval = TimeInterval.random(in: 300 ... 400)

        let presentingAlert = alertCampaign()
        let secondAlert = alertCampaign()
        memoryCache.setAlertsData([presentingAlert, secondAlert])

        let displayingExpectation = XCTestExpectation()

        let notDisplayingExpectation = XCTestExpectation()
        notDisplayingExpectation.isInverted = true

        let presenter = MockAlertPresenter()
        presenter.didFinishPresentingAlertClosure = { presenter, alert in
            XCTAssertEqual(presentingAlert, alert)
            XCTAssertFalse(self.memoryCache.alerts.isEmpty)

            let impression = self.stateKeeper.impressionIDs.first!
            XCTAssertEqual(impression, presentingAlert.identifier)

            XCTAssertEqual(self.stateKeeper.lastDisplayTimeInterval,
                           self.timeFetcher.currentTimestamp(),
                           accuracy: 0.1)

            if alert === presentingAlert {
                displayingExpectation.fulfill()
            }
            else if alert === secondAlert {
                notDisplayingExpectation.fulfill()
            }
        }

        let executor = CLMDisplayExecutor(settings: settings,
                                          timeFetcher: timeFetcher,
                                          clientInfo: clientInfo,
                                          memoryCache: memoryCache,
                                          stateKeeper: stateKeeper)
        executor.alertPresenter = presenter

        executor.checkAndDisplayNextAppForegroundAlert()
        executor.checkAndDisplayNextAppForegroundAlert()

        wait(for: [displayingExpectation, notDisplayingExpectation], timeout: 1.0)
    }

    // MARK: Private

    private func performDisplayingTest(trigger: CLMAlertCampaignTrigger) {
        timeFetcher.timeInterval = TimeInterval.random(in: 300 ... 400)

        let presentingAlert = alertCampaign()
        presentingAlert.trigger = trigger
        memoryCache.setAlertsData([presentingAlert])

        let expectation = XCTestExpectation()

        let presenter = MockAlertPresenter()
        presenter.didFinishPresentingAlertClosure = { presenter, alert in
            XCTAssertEqual(presentingAlert, alert)

            XCTAssertTrue(self.memoryCache.alerts.isEmpty)

            let impression = self.stateKeeper.impressionIDs.first!
            XCTAssertEqual(impression, presentingAlert.identifier)

            XCTAssertEqual(self.stateKeeper.lastDisplayTimeInterval,
                           self.timeFetcher.currentTimestamp(),
                           accuracy: 0.1)

            expectation.fulfill()
        }

        let executor = CLMDisplayExecutor(settings: settings,
                                          timeFetcher: timeFetcher,
                                          clientInfo: clientInfo,
                                          memoryCache: memoryCache,
                                          stateKeeper: stateKeeper)
        executor.alertPresenter = presenter

        switch trigger {
        case .onAppLaunch:
            executor.checkAndDisplayNextAppLaunchAlert()
        case .onForeground:
            executor.checkAndDisplayNextAppForegroundAlert()
        default:
            XCTFail("Trigger \(trigger.rawValue) is not handled")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    private func alertCampaign() -> CLMAlertCampaign {
        let alert = CLMAlertCampaign.testAlertCampaign()
        return alert
    }
}
