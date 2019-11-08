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

final class AlertButtonsTranslationViewController: UIViewController {
    private let model: AlertButtonsTranslationModel
    private lazy var formController = GroupedFormTableViewController()

    init(alertCampaign: CLMAlertCampaign, translation: CLMAlertTranslation) {
        model = AlertButtonsTranslationModel(alertCampaign: alertCampaign, translation: translation)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable)
    init() {
        fatalError("init() has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Buttons Translations"

        displayController(formController, inContentView: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        model.updateTranslation()
    }

    private func reloadData() {
        var items = [FormCellModel]()

        for buttonTranslation in model.buttons {
            let titleModel = TextFieldFormCellModel()
            titleModel.title = "Title"
            titleModel.text = buttonTranslation.title
            titleModel.placeholder = buttonTranslation.originalTitle
            titleModel.returnKeyType = .next
            titleModel.didChangeText = { titleModel in
                buttonTranslation.title = titleModel.text ?? ""
            }
            items.append(titleModel)
        }

        let section = FormSectionModel(items)
        formController.setSections([section])
    }
}
