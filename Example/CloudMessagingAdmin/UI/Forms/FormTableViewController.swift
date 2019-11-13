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

import UIKit

class FormTableViewController: UITableViewController {
    private(set) var sections: [FormSectionModel]?

    private var cellModelToCellClass: [String: UITableViewCell.Type]

    init(style: UITableView.Style, cellModelToCellClass: [String: UITableViewCell.Type]) {
        self.cellModelToCellClass = cellModelToCellClass

        super.init(style: style)
    }

    @available(*, unavailable)
    override init(style: UITableView.Style) {
        fatalError("init(style:) has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSections(_ sections: [FormSectionModel], shouldReload: Bool = true) {
        self.sections = sections

        if shouldReload {
            tableView.reloadData()
        }
    }

    func showInvalidInputForModel(_ model: FormCellModel) {
        if let indexPath = indexPath(for: model), let cell = tableView.cellForRow(at: indexPath) {
            cell.shakeView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.keyboardDismissMode = .onDrag

        for cellDescription in cellModelToCellClass {
            tableView.register(cellDescription.value, forCellReuseIdentifier: cellDescription.key)
        }
    }

    // MARK: Private

    private func indexPath(for model: FormCellModel) -> IndexPath? {
        guard let sections = sections else {
            return nil
        }

        var sectionIndex = 0
        for section in sections {
            if let rowIndex = section.items.firstIndex(where: { $0 === model }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }

            sectionIndex += 1
        }

        return nil
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = sections else {
            return 0
        }

        let sectionModel = sections[section]

        return sectionModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sections = sections else {
            fatalError("Invalid state")
        }

        let sectionModel = sections[indexPath.section]
        let items = sectionModel.items

        // swiftlint:disable force_cast
        let item = items[indexPath.row]
        if let textFieldCellModel = item as? TextFieldFormCellModel {
            let reuseIdentifier = String(describing: TextFieldFormCellModel.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                     for: indexPath) as! TextFieldFormTableViewCell
            cell.model = textFieldCellModel
            cell.delegate = self
            return cell
        }
        else if let textViewCellModel = item as? TextViewFormCellModel {
            let reuseIdentifier = String(describing: TextViewFormCellModel.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                     for: indexPath) as! TextViewFormTableViewCell
            cell.model = textViewCellModel
            cell.delegate = self
            return cell
        }
        else if let datePickerCellModel = item as? DatePickerFormCellModel {
            let reuseIdentifier = String(describing: DatePickerFormCellModel.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                     for: indexPath) as! DatePickerFormTableViewCell
            cell.model = datePickerCellModel
            cell.delegate = self
            return cell
        }
        else if let selectorCellModel = item as? SelectorFormCellModel {
            let reuseIdentifier = String(describing: SelectorFormCellModel.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                     for: indexPath) as! SelectorFormTableViewCell
            cell.model = selectorCellModel
            return cell
        }
        else if let switcherCellModel = item as? SwitcherFormCellModel {
            let reuseIdentifier = String(describing: SwitcherFormCellModel.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                     for: indexPath) as! SwitcherFormTableViewCell
            cell.model = switcherCellModel
            return cell
        }
        else {
            fatalError("Unsupported cell model: \(item)")
        }
        // swiftlint:enable force_cast
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let sections = sections else {
            fatalError("Invalid state")
        }

        let sectionModel = sections[indexPath.section]
        let items = sectionModel.items

        if let selectorCellModel = items[indexPath.row] as? SelectorFormCellModel, selectorCellModel.isEnabled {
            selectorCellModel.action?()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = sections else {
            fatalError("Invalid state")
        }

        let sectionModel = sections[section]

        return sectionModel.header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sections = sections else {
            fatalError("Invalid state")
        }

        let sectionModel = sections[section]

        return sectionModel.footer
    }
}

extension FormTableViewController: TextInputFormTableViewCellDelegate {
    func textInputFormTableViewCellNextResponderOrDone(_ cell: TextInputFormTableViewCell) {
        guard let sections = sections else {
            fatalError("Invalid state")
        }

        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        for section in indexPath.section ..< sections.count {
            let sectionModel = sections[section]
            var row = (indexPath.section == section) ? indexPath.row + 1 : 0
            while row < sectionModel.items.count {
                let cellModel = sectionModel.items[row]
                if cellModel is TextInputFormCellModel {
                    let indexPath = IndexPath(row: row, section: section)
                    if let cell = tableView.cellForRow(at: indexPath) as? TextInputFormTableViewCell {
                        cell.textInputBecomeFirstResponder()
                    }

                    return
                }

                row += 1
            }
        }

        view.endEditing(true)
    }
}
