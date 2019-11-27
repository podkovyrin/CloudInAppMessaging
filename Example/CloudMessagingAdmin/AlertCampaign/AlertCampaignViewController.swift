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

protocol AlertCampaignViewControllerDelegate: AnyObject {
    func alertCampaignViewController(didCancel controller: AlertCampaignViewController)
    func alertCampaignViewController(_ controller: AlertCampaignViewController,
                                     didFinishWith alertCampaign: CLMAlertCampaign)
}

private let MaxDisplayedDetailItems = 6

final class AlertCampaignViewController: UIViewController {
    weak var delegate: AlertCampaignViewControllerDelegate?

    private let model: AlertCampaignModel
    private lazy var formController = GroupedFormTableViewController()
    private lazy var alertPresenter: CLMAlertPresenter = {
        let alertPresenter = CLMDefaultAlertPresenter()
        alertPresenter.actionExecutor = DummyAlertActionExecutor()
        return alertPresenter
    }()

    init(alertCampaign: CLMAlertCampaign?, service: AlertCampaignCloudKitService) {
        if let alertCampaign = alertCampaign {
            // swiftlint:disable force_cast
            model = AlertCampaignModel(alertCampaign: alertCampaign.copy() as! CLMAlertCampaign,
                                       service: service)
            // swiftlint:enable force_cast
        }
        else {
            model = AlertCampaignModel(service: service)
        }

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

        title = "Alert Campaign"

        let previewItem = UIBarButtonItem(title: "Preview",
                                          style: .plain,
                                          target: self,
                                          action: #selector(previewButtonAction))
        navigationItem.leftBarButtonItem = previewItem

        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                         target: self,
                                         action: #selector(cancelAction))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done,
                                       target: self,
                                       action: #selector(doneAction))
        navigationItem.rightBarButtonItems = [doneItem, cancelItem]

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

    // MARK: Form

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

    private var alertTitle: TextViewFormCellModel {
        let cellModel = TextViewFormCellModel()
        cellModel.title = "Alert Title"
        cellModel.text = model.alertCampaign.title
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.title = cellModel.text
        }

        return cellModel
    }

    private var alertMessage: TextViewFormCellModel {
        let cellModel = TextViewFormCellModel()
        cellModel.title = "Alert Message"
        cellModel.text = model.alertCampaign.message
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.message = cellModel.text
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

    private var bundleIdentifier: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Bundle ID"
        cellModel.text = model.alertCampaign.bundleIdentifier
        cellModel.placeholder = "com.example.myapp"
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.bundleIdentifier = cellModel.text
        }

        return cellModel
    }

    private var countries: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Countries"
        let allCount = model.localeCodes.countryCodes.count
        let countries = model.alertCampaign.countries
        let count = countries.count
        if allCount == count {
            cellModel.detail = "All Countries"
        }
        else {
            if count > MaxDisplayedDetailItems {
                cellModel.detail = "\(count) / \(allCount)"
            }
            else {
                cellModel.detail = countries.joined(separator: ", ")
            }
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
        let allCount = model.localeCodes.languageCodes.count
        let languages = model.alertCampaign.languages
        let count = languages.count
        if allCount == count {
            cellModel.detail = "All Languages"
        }
        else {
            if count > MaxDisplayedDetailItems {
                cellModel.detail = "\(count) / \(allCount)"
            }
            else {
                cellModel.detail = languages.joined(separator: ", ")
            }
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
        cellModel.transformAction = { [weak self] string in
            guard let self = self else { return nil }
            return self.versionStringTransformer(string)
        }
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.maxAppVersion = self.trimVersionString(cellModel.text)
        }

        return cellModel
    }

    private var maxOSVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Max iOS Version"
        cellModel.text = model.alertCampaign.maxOSVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"
        cellModel.transformAction = { [weak self] string in
            guard let self = self else { return nil }
            return self.versionStringTransformer(string)
        }
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.maxOSVersion = self.trimVersionString(cellModel.text)
        }

        return cellModel
    }

    private var minAppVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Min App Version"
        cellModel.text = model.alertCampaign.minAppVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"
        cellModel.transformAction = { [weak self] string in
            guard let self = self else { return nil }
            return self.versionStringTransformer(string)
        }
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.minAppVersion = self.trimVersionString(cellModel.text)
        }

        return cellModel
    }

    private var minOSVersion: TextFieldFormCellModel {
        let cellModel = TextFieldFormCellModel()
        cellModel.title = "Min iOS Version"
        cellModel.text = model.alertCampaign.minOSVersion
        cellModel.keyboardType = .decimalPad
        cellModel.placeholder = "Any"
        cellModel.transformAction = { [weak self] string in
            guard let self = self else { return nil }
            return self.versionStringTransformer(string)
        }
        cellModel.didChangeText = { [weak self] cellModel in
            guard let self = self else { return }
            self.model.alertCampaign.minOSVersion = self.trimVersionString(cellModel.text)
        }

        return cellModel
    }

    private var startDate: DatePickerFormCellModel {
        let cellModel = DatePickerFormCellModel()
        cellModel.title = "Start Date"
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
        cellModel.title = "End Date"
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

    private var validate: SelectorFormCellModel {
        let cellModel = SelectorFormCellModel()
        cellModel.title = "Validate Alert Campaign"
        cellModel.titleStyle = .tinted
        cellModel.action = { [weak self] in
            guard let self = self else { return }

            let message = self.model.alertCampaign.validate() ?? "✅ Perfect!"
            let alert = UIAlertController(title: "Validation Result",
                                          message: message,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(okAction)
            self.present(alert, animated: true)
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
            bundleIdentifier, countries, languages, maxAppVersion, maxOSVersion, minAppVersion, minOSVersion,
        ])
        targetingSection.header = "Targeting"

        let schedulingSection = FormSectionModel([startDate, endDate, trigger])
        let timezone = TimeZone.current
        let timezoneInfo = timezone.abbreviation() ?? timezone.identifier
        schedulingSection.header = "Scheduling (\(timezoneInfo))"

        let maintenanceSection = FormSectionModel([validate])
        maintenanceSection.header = "– Maintenance –"

        return [alertSection,
                buttonsSection,
                localizationSecion,
                targetingSection,
                schedulingSection,
                maintenanceSection]
    }

    // MARK: Actions

    @objc
    private func cancelAction() {
        delegate?.alertCampaignViewController(didCancel: self)
    }

    @objc
    private func doneAction() {
        let message = model.alertCampaign.validate()
        if message != nil {
            let alert = UIAlertController(title: "Validation Result",
                                          message: message,
                                          preferredStyle: .alert)
            let proceedAction = UIAlertAction(title: "Proceed anyway",
                                              style: .destructive,
                                              handler: { _ in
                                                  self.saveAndFinish()
            })
            alert.addAction(proceedAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }
        else {
            saveAndFinish()
        }
    }

    @objc
    private func previewButtonAction() {
        let previewAction: (String) -> Void = { langCode in
            self.alertPresenter.present(alert: self.model.alertCampaign,
                                        preferredLanguages: [langCode],
                                        in: self)
        }

        let alert = UIAlertController(title: "Preview Alert Campaign",
                                      message: "Select Alert Locale",
                                      preferredStyle: .actionSheet)

        guard let langCode = model.alertCampaign.defaultLangCode else {
            fatalError("Default Lang Code is not set")
        }

        let defaultAction = UIAlertAction(title: "Default Locale: \(langCode)", style: .default) { _ in
            previewAction(langCode)
        }
        alert.addAction(defaultAction)

        for translation in model.alertCampaign.translations {
            if let langCode = translation.langCode {
                let action = UIAlertAction(title: "Locale: \(langCode)", style: .default) { _ in
                    previewAction(langCode)
                }
                alert.addAction(action)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true)
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

    private func showTranslationsController() {
        let controller = AlertCampaignTranslationsViewController(alertCampaign: model.alertCampaign,
                                                                 languageCodes: model.localeCodes.languageCodes,
                                                                 locale: model.locale)
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showCountriesController() {
        let countryCodes = model.countriesModel()

        let controller = SearchSelectorViewController(model: countryCodes) { [weak self] items in
            guard let self = self else { return }

            self.model.alertCampaign.countries = items.map { $0.code }
            self.reloadData()
        }
        controller.title = "🎯 Countries"
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showLanguagesController() {
        let languageCodes = model.languagesModel()

        let controller = SearchSelectorViewController(model: languageCodes) { [weak self] items in
            guard let self = self else { return }

            self.model.alertCampaign.languages = items.map { $0.code }
            self.reloadData()
        }
        controller.title = "🎯 Languages"
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
                    textField.text = trigger.rawValue.trimmingCharacters(in: .whitespaces)
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

    // MARK: Private

    private func reloadData() {
        formController.setSections(formSections)
    }

    private func saveAndFinish() {
        model.save(model.alertCampaign) { [weak self] errors in
            guard let self = self else { return }

            if !errors.isEmpty {
                self.displayErrorsIfNeeded(errors)
            }
            else {
                self.delegate?.alertCampaignViewController(self, didFinishWith: self.model.alertCampaign)
            }
        }
    }

    private func trimVersionString(_ version: String?) -> String? {
        guard let version = version else {
            return nil
        }

        let trimmed = version.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return nil
        }

        // fix separator in some locales
        let fixed = trimmed.replacingOccurrences(of: ",", with: ".")

        // remove any leading/trailing separators
        let componets = fixed.components(separatedBy: ".").filter { !$0.isEmpty }

        return componets.joined(separator: ".")
    }

    private func versionStringTransformer(_ version: String?) -> String? {
        guard let trimmed = trimVersionString(version) else {
            return nil
        }

        if let version = version, version.hasSuffix(".") || version.hasSuffix(",") {
            return trimmed + "."
        }

        return trimmed
    }
}
