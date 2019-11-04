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

protocol AddAlertCampaignViewControllerDelegate: AnyObject {
    func addAlertCampaignViewController(_ controller: AddAlertCampaignViewController,
                                        didFinishWith alertCampaign: CLMAlertCampaign)
}

class AddAlertCampaignViewController: UIViewController {
    weak var delegate: AddAlertCampaignViewControllerDelegate?

    private let model = AddAlertCampaignModel()

    private lazy var identifierButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0,
                                                left: Styles.Sizes.padding,
                                                bottom: 0.0,
                                                right: Styles.Sizes.padding)
        button.tintColor = Styles.Colors.textColor
        button.addTarget(self, action: #selector(identifierButtonAction), for: .touchUpInside)

        return button
    }()

    private lazy var formController = GroupedFormTableViewController()

    private var alertTitle: TextViewFormCellModel {
        let cellModel = TextViewFormCellModel()
        cellModel.title = "Alert Title"
        cellModel.text = model.alertCampaign.alertTitle
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.alertTitle = cellModel.text
        }

        return cellModel
    }

    private var alertMessage: TextViewFormCellModel {
        let cellModel = TextViewFormCellModel()
        cellModel.title = "Alert Message"
        cellModel.text = model.alertCampaign.alertMessage
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.alertMessage = cellModel.text
        }

        return cellModel
    }

    private var buttons: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Alert Buttons"
        let buttonTitles = model.alertCampaign.buttonTitles
        cellModel.detail = buttonTitles.isEmpty ? "<No Buttons>" : buttonTitles.joined(separator: ", ")
        cellModel.accessoryType = .disclosureIndicator
        cellModel.action = { [weak self] in
            guard let self = self else { return }
            self.showButtonsController()
        }

        return cellModel
    }

    private var defaultLangCode: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Default Lang Code"
        cellModel.detail = model.alertCampaign.defaultLangCode
        cellModel.accessoryType = .disclosureIndicator
        cellModel.action = { [weak self] in
            guard let self = self else { return }
            self.showDefaultLangCodeSelector()
        }

        return cellModel
    }

    private var translations: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Translations"
        cellModel.detail = "\(model.alertCampaign.translations.count)"
        cellModel.accessoryType = .disclosureIndicator
        cellModel.action = { [weak self] in
            guard let self = self else { return }
            self.showTranslationsController()
        }

        return cellModel
    }

    private var countries: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Countries"
        let countries = model.alertCampaign.countries
        if countries.isEmpty {
            cellModel.detail = "All Countries"
        }
        else {
            cellModel.detail = countries.joined(separator: ", ")
        }
        cellModel.accessoryType = .disclosureIndicator
        cellModel.action = { [weak self] in
            guard let self = self else { return }
            self.showCountriesController()
        }

        return cellModel
    }

    private var languages: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Languages"
        let languages = model.alertCampaign.languages
        if languages.isEmpty {
            cellModel.detail = "All Languages"
        }
        else {
            cellModel.detail = languages.joined(separator: ", ")
        }
        cellModel.accessoryType = .disclosureIndicator
        cellModel.action = { [weak self] in
            guard let self = self else { return }
            self.showLanguagesController()
        }

        return cellModel
    }

    private var maxAppVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Max App Version"
        cellModel.text = model.alertCampaign.maxAppVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"

        return cellModel
    }

    private var maxOSVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Max iOS Version"
        cellModel.text = model.alertCampaign.maxOSVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"

        return cellModel
    }

    private var minAppVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Min App Version"
        cellModel.text = model.alertCampaign.minAppVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"

        return cellModel
    }

    private var minOSVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Min iOS Version"
        cellModel.text = model.alertCampaign.minOSVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"

        return cellModel
    }

    private var startDate: DatePickerFormCellModel {
        let cellModel = DatePickerFormCellModel()
        cellModel.title = "Start Date (GMT +0)"
        cellModel.date = model.alertCampaign.startDate
        cellModel.minDate = Date()
        cellModel.placeholder = "Starts Now"
        cellModel.didChangeDate = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.startDate = cellModel.date
        }

        return cellModel
    }

    private var endDate: DatePickerFormCellModel {
        let cellModel = DatePickerFormCellModel()
        cellModel.title = "End Date (GMT +0)"
        cellModel.date = model.alertCampaign.endDate
        cellModel.minDate = Date()
        cellModel.placeholder = "No End Date"
        cellModel.didChangeDate = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.endDate = cellModel.date
        }

        return cellModel
    }

    private var trigger: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Trigger"
        cellModel.detail = model.alertCampaign.trigger?.description
        cellModel.action = { [weak self] in
            guard let self = self else { return }
            self.showTriggerSelector()
        }

        return cellModel
    }

    private var formSections: [FormSectionModel] {
        let alertSection = FormSectionModel([alertTitle, alertMessage])
        alertSection.header = "Alert"

        let buttonsSection = FormSectionModel([buttons])
        buttonsSection.header = "Buttons"

        let localizationSecion = FormSectionModel([defaultLangCode, translations])
        localizationSecion.header = "Localization"

        let targetingSection = FormSectionModel([
            countries, languages, maxAppVersion, maxOSVersion, minAppVersion, minOSVersion,
        ])
        targetingSection.header = "Targeting"

        let schedulingSection = FormSectionModel([startDate, endDate, trigger])
        schedulingSection.header = "Scheduling"

        return [alertSection, buttonsSection, localizationSecion, targetingSection, schedulingSection]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Alert Campaign"

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(doneAction))
        navigationItem.rightBarButtonItem = doneButton

        displayController(formController, inContentView: view)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let buttonHeight: CGFloat = 44.0
        let width: CGFloat = view.bounds.width
        identifierButton.frame = CGRect(x: 0.0, y: 0.0, width: width, height: buttonHeight)
        formController.tableView.tableHeaderView = identifierButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // reload data
        formController.setSections(formSections)
        identifierButton.setTitle(model.alertCampaign.identifier, for: .normal)
    }

    @objc
    private func doneAction() {
        delegate?.addAlertCampaignViewController(self, didFinishWith: model.alertCampaign)
    }

    private func showButtonsController() {
        let controller = AlertCamaignButtonsViewController(alertCampaign: model.alertCampaign)
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showDefaultLangCodeSelector() {
        let languageCodes = model.defaultLanguageModel()

        let controller = SearchSelectorViewController(model: languageCodes) { [weak self] items in
            guard let self = self else { return }
            guard let item = items.first else {
                fatalError("Inconsistent state")
            }
            self.model.alertCampaign.defaultLangCode = item.code
            self.reloadData()

            self.navigationController?.popViewController(animated: true)
        }
        controller.title = "Default Lang Code"
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showTranslationsController() {}

    private func showCountriesController() {
        let countryCodes = model.countriesModel()

        let controller = SearchSelectorViewController(model: countryCodes) { [weak self] items in
            guard let self = self else { return }

            self.model.alertCampaign.countries = items.map { $0.code }
            self.reloadData()
        }
        controller.title = "Countries"
        controller.multiSelection = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showLanguagesController() {
        let languageCodes = model.languagesModel()

        let controller = SearchSelectorViewController(model: languageCodes) { [weak self] items in
            guard let self = self else { return }

            self.model.alertCampaign.languages = items.map { $0.code }
            self.reloadData()
        }
        controller.title = "Languages"
        controller.multiSelection = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showTriggerSelector() {
        let trigger = model.alertCampaign.trigger

        let alert = UIAlertController(title: "Select Trigger",
                                      message: "Or input custom trigger event string",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none

            if let trigger = trigger {
                switch trigger {
                case .onForeground:
                    break
                case .onAppLaunch:
                    break
                default:
                    textField.text = trigger.rawValue
                }
            }
        }

        let defaultTriggers = [CLMAlertCampaignTrigger.onForeground, .onAppLaunch]
        for trigger in defaultTriggers {
            let action = UIAlertAction(title: trigger.description,
                                       style: .default) { _ in
                self.model.alertCampaign.trigger = trigger
                self.reloadData()
            }
            alert.addAction(action)
        }

        let customAction = UIAlertAction(title: "Use Custom Action", style: .default) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else { return }
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedText.isEmpty {
                self.model.alertCampaign.trigger = CLMAlertCampaignTrigger(rawValue: trimmedText)
                self.reloadData()
            }
        }
        alert.addAction(customAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    @objc
    private func identifierButtonAction() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = model.alertCampaign.identifier
    }

    private func reloadData() {
        formController.setSections(formSections)
    }
}
