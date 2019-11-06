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
import UIKit

class AlertCampaignListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let updateItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                         target: self,
                                         action: #selector(updateButtonAction(_:)))
        navigationItem.leftBarButtonItem = updateItem

        let addItem = UIBarButtonItem(barButtonSystemItem: .add,
                                      target: self,
                                      action: #selector(addButtonAction(_:)))
        navigationItem.rightBarButtonItem = addItem
    }

    // MARK: Actions

    @objc
    private func updateButtonAction(_ sender: Any) {}

    @objc
    private func addButtonAction(_ sender: Any) {
        let controller = AlertCampaignViewController()
        controller.delegate = self
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }
}

extension AlertCampaignListViewController: AlertCampaignViewControllerDelegate {
    func alertCampaignViewController(didCancel controller: AlertCampaignViewController) {
        dismiss(animated: true)
    }

    func alertCampaignViewController(_ controller: AlertCampaignViewController,
                                     didFinishWith alertCampaign: CLMAlertCampaign) {
        dismiss(animated: true)
    }
}
