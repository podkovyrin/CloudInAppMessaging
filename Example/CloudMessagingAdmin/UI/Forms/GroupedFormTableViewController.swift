//
//  GroupedFormTableViewController.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class GroupedFormTableViewController: FormTableViewController {
    init() {
        let cellModelToCellClass = [
            String(describing: SelectorFormCellModel.self): GroupedSelectorFormTableViewCell.self,
            String(describing: SwitcherFormCellModel.self): GroupedSwitcherFormTableViewCell.self,
            String(describing: TextViewFormCellModel.self): GroupedTextViewFormTableViewCell.self,
            String(describing: TextFieldFormCellModel.self): GroupedTextFieldFormTableViewCell.self,
            String(describing: DatePickerFormCellModel.self): GroupedDatePickerFormTableViewCell.self,
        ]
        super.init(style: .grouped, cellModelToCellClass: cellModelToCellClass)
    }
}
