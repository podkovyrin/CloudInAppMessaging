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

import Foundation

class MockTimeFetcher: CLMTimeFetcher {
    var timeInterval: TimeInterval = 100

    override func currentTimestamp() -> TimeInterval {
        return timeInterval
    }
}

class MockAlertCampaignFetcher: CLMAlertCampaignFetcher {
    var alerts = [CLMAlertCampaign]()
    let translations = [CLMAlertTranslation]()

    func fetchAlertCampaignsCompletion(_ completion: @escaping ([CLMAlertCampaign]) -> Void) {
        completion(alerts)
    }

    func fetchTranslations(for alertCampaign: CLMAlertCampaign,
                           completion: @escaping ([CLMAlertTranslation]) -> Void) {
        completion(translations)
    }
}

class MockClientInfo: CLMClientInfo {
    override var bundleIdentifier: String { "not.used.in.tests" }
    override var preferredLanguages: [String] { ["en"] }
    override var countryCode: String? { "us" }
    override var appVersion: String { "1.0" }
    override var osVersion: String { "13" }
}

class MockFetchFlowDelegate: CLMFetchFlowDelegate {
    var didFinishClosure: ((CLMFetchFlow, Bool) -> Void)?

    func fetchFlowDidFinish(_ fetchFlow: CLMFetchFlow, initialAppLaunch: Bool) {
        didFinishClosure?(fetchFlow, initialAppLaunch)
    }
}

class MockAlertPresenter: CLMAlertPresenter {
    var didFinishPresentingAlertClosure: ((CLMAlertPresenter, CLMAlertCampaign) -> Void)?

    var actionExecutor: CLMAlertActionExecutor? // not used

    weak var delegate: CLMAlertPresenterDelegate?

    func present(alert alertCampaign: CLMAlertCampaign, preferredLanguages: [String], in controller: UIViewController) {
        DispatchQueue.main.async {
            self.delegate?.alertPresenter(self, didFinishPresentingAlert: alertCampaign)
            self.didFinishPresentingAlertClosure?(self, alertCampaign)
        }
    }
}
