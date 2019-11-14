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
import CloudKit
import Foundation

final class AlertCampaignListModel {
    private(set) var alerts = [CLMAlertCampaign]()

    var canUpdate: Bool {
        service.isConfigured
    }

    let service: AlertCampaignCloudKitService

    init(service: AlertCampaignCloudKitService) {
        self.service = service
    }

    func update(completion: @escaping ([Error]) -> Void) {
        service.fetch { [weak self] alerts, errors in
            if !errors.isEmpty {
                completion(errors)
            }
            else {
                guard let self = self else { return }

                self.alerts = alerts
                completion(errors)
            }
        }
    }

    func delete(_ alertCampaign: CLMAlertCampaign, completion: @escaping ([Error]) -> Void) {
        service.delete(alertCampaign) { [weak self] errors in
            guard let self = self else { return }

            if errors.isEmpty {
                self.alerts.removeAll { $0 === alertCampaign }
            }

            completion(errors)
        }
    }

    /// Creates test AlertCampaign to define schema on CloudKit
    func createTestAlertCampaign() {
        let alertCampaign = CLMAlertCampaign.testAlertCampaign()
        assert(alertCampaign.validate() == nil)

        service.save(alertCampaign) { errors in
            print("Creating test alert campaign done: \(errors)")
        }
    }
}
