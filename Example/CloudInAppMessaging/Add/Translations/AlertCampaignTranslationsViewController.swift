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

class AlertCampaignTranslationsViewController: UIViewController {
    private let model: AlertTranslationsModel
    private lazy var formController = GroupedFormTableViewController()

    init(alertCampaign: CLMAlertCampaign, languageCodes: [String], locale: Locale) {
        model = AlertTranslationsModel(alertCampaign: alertCampaign,
                                       languageCodes: languageCodes,
                                       locale: locale)
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

        title = "Translations"

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

    // MARK: Private

    private func reloadData() {
        var sections = [FormSectionModel]()
        for translation in model.translations {
            sections.append(section(for: translation))
        }
        formController.setSections(sections)
    }

    private func section(for translation: CLMAlertTranslation) -> FormSectionModel {
        let identifierModel = SelectorFormCellModel()
        identifierModel.title = "Identifier"
        identifierModel.detail = translation.identifier
        identifierModel.action = {
            UIPasteboard.general.string = translation.identifier
        }

        let languageModel = SelectorFormCellModel()
        languageModel.title = "Translation Language"
        languageModel.detail = translation.langCode
        languageModel.accessoryType = .disclosureIndicator
        languageModel.action = { [weak self] in
            guard let self = self else { return }
            self.showTranslationLanguageSelector(translation)
        }

        let titleModel = TextViewFormCellModel()
        titleModel.title = "Alert Title"
        titleModel.text = translation.title
        titleModel.placeholder = model.alertCampaign.title
        titleModel.didChangeText = { cellModel in
            translation.title = cellModel.text?.trimmingCharacters(in: .whitespaces)
        }

        let messageModel = TextViewFormCellModel()
        messageModel.title = "Alert Message"
        messageModel.text = translation.message
        messageModel.placeholder = model.alertCampaign.message
        messageModel.didChangeText = { cellModel in
            translation.message = cellModel.text?.trimmingCharacters(in: .whitespaces)
        }

        let buttonsModel = SelectorFormCellModel()
        buttonsModel.title = "Alert Buttons"
        buttonsModel.detail = "\(translation.buttonTitles.count)"
        buttonsModel.accessoryType = .disclosureIndicator
        buttonsModel.action = { [weak self] in
            guard let self = self else { return }
            self.showButtonsController(translation)
        }

        let removeModel = SelectorFormCellModel()
        removeModel.title = "Remove Translation"
        removeModel.titleStyle = .destructive
        removeModel.action = { [weak self] in
            guard let self = self else { return }
            self.model.removeTranslation(translation)
            self.reloadData()
        }

        let section = FormSectionModel(
            [identifierModel, languageModel, titleModel, messageModel, buttonsModel, removeModel]
        )

        return section
    }

    // MARK: Actions

    @objc
    private func addAction() {
        model.addTranslation()
        reloadData()
    }

    private func showTranslationLanguageSelector(_ translation: CLMAlertTranslation) {
        let languageCodes = model.languageModel(for: translation)

        let controller = SearchSelectorViewController(model: languageCodes) { [weak self] items in
            guard let self = self else { return }
            guard let item = items.first else {
                fatalError("Inconsistent state")
            }
            translation.langCode = item.code
            self.reloadData()

            self.navigationController?.popViewController(animated: true)
        }
        controller.title = "Translation Language"
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showButtonsController(_ translation: CLMAlertTranslation) {
        let controller = AlertButtonsTranslationViewController(alertCampaign: model.alertCampaign,
                                                               translation: translation)
        navigationController?.pushViewController(controller, animated: true)
    }
}
