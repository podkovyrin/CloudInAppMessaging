//
//  GroupedSelectorFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

class GroupedSelectorFormTableViewCell: UITableViewCell, SelectorFormTableViewCell {
    var model: SelectorFormCellModel? {
        didSet {
            textLabel?.text = model?.title
            detailTextLabel?.text = model?.detail

            if let model = model {
                textLabel?.textColor = model.titleStyle == .default ? Styles.Colors.textColor : Styles.Colors.tintColor
                selectionStyle = model.isEnabled ? .default : .none
                accessoryType = model.accessoryType
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
