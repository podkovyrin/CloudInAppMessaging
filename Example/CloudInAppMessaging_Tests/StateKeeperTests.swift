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

class StateKeeperTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "clm.stateKeeperTest")!
    }

    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removePersistentDomain(forName: "clm.stateKeeperTest")
    }

    func testRecordImpression() {
        let timeFetcher = MockTimeFetcher()
        let stateKeeper = CLMStateKeeper(userDefaults: userDefaults, timeFetcher: timeFetcher)

        var alert = alertCampaign()
        stateKeeper.recordAlertImpression(alert)

        var impressions = stateKeeper.impressionIDs

        XCTAssertEqual(impressions.count, 1)
        XCTAssertEqual(impressions.first!, alert.identifier)
        XCTAssertEqual(stateKeeper.lastDisplayTimeInterval, timeFetcher.currentTimestamp(), accuracy: 0.1)

        // Second displaying

        timeFetcher.timeInterval = 1234
        alert = alertCampaign()
        stateKeeper.recordAlertImpression(alert)

        impressions = stateKeeper.impressionIDs

        XCTAssertEqual(impressions.count, 2)
        XCTAssertEqual(impressions.last!, alert.identifier)
        XCTAssertEqual(stateKeeper.lastDisplayTimeInterval, timeFetcher.currentTimestamp(), accuracy: 0.1)
    }

    func testRecordFetch() {
        let timeFetcher = MockTimeFetcher()
        let stateKeeper = CLMStateKeeper(userDefaults: userDefaults, timeFetcher: timeFetcher)

        stateKeeper.recordFetch()
        XCTAssertEqual(stateKeeper.lastFetchTimeInterval, timeFetcher.currentTimestamp(), accuracy: 0.1)

        // Second fetch

        timeFetcher.timeInterval = 1234
        stateKeeper.recordFetch()
        XCTAssertEqual(stateKeeper.lastFetchTimeInterval, timeFetcher.currentTimestamp(), accuracy: 0.1)
    }

    // MARK: Private

    private func alertCampaign() -> CLMAlertCampaign {
        return CLMAlertCampaign.testAlertCampaign()
    }
}
