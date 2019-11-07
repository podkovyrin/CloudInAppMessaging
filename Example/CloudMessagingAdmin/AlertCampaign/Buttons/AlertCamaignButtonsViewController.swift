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

final class AlertCamaignButtonsViewController: UIViewController {
    private let model: AlertCampaignButtonsModel
    private lazy var formController = GroupedFormTableViewController()

    init(alertCampaign: CLMAlertCampaign) {
        model = AlertCampaignButtonsModel(alertCampaign: alertCampaign)
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

        title = "Buttons"

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        navigationItem.rightBarButtonItem = addItem

        displayController(formController, inContentView: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        model.updateAlertCampaign()
    }

    private func section(for button: AlertCampaignButton) -> FormSectionModel {
        let titleModel = TextFieldFormCellModel()
        titleModel.title = "Title"
        titleModel.text = button.title
        titleModel.returnKeyType = .next
        titleModel.didChangeText = { titleModel in
            button.title = titleModel.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }

        let urlModel = TextFieldFormCellModel()
        urlModel.title = "URL"
        urlModel.text = button.url == CLMAlertCampaign.ButtonURLNoAction ? nil : button.url
        urlModel.placeholder = "No Action"
        urlModel.returnKeyType = .done
        urlModel.autocorrectionType = .no
        urlModel.autocapitalizationType = .none
        urlModel.didChangeText = { titleModel in
            button.url = titleModel.text?.trimmingCharacters(in: .whitespaces) ?? ""
        }
        urlModel.validateAction = { [weak self, weak urlModel] text in
            guard let self = self, let urlModel = urlModel else { return false }

            if text.isEmpty {
                return true
            }
            else {
                if let url = URL(string: text), url.scheme != nil {
                    return true
                }
                else {
                    self.formController.showInvalidInputForModel(urlModel)
                    return false
                }
            }
        }

        let removeModel = SelectorFormCellModel()
        removeModel.title = "Remove Button"
        removeModel.titleStyle = .destructive
        removeModel.action = { [weak self] in
            guard let self = self else { return }
            self.model.removeButton(button)
            self.reloadData()
        }

        return FormSectionModel([titleModel, urlModel, removeModel])
    }

    private func reloadData() {
        var sections = [FormSectionModel]()
        for button in model.buttons {
            sections.append(section(for: button))
        }
        formController.setSections(sections)
    }

    @objc
    private func addAction() {
        model.addButton()
        reloadData()
    }
}
