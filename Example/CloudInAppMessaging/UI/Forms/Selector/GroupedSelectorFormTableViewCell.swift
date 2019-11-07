//
//  GroupedSelectorFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class GroupedSelectorFormTableViewCell: UITableViewCell, SelectorFormTableViewCell {
    var model: SelectorFormCellModel? {
        didSet {
            textLabel?.text = model?.title
            detailTextLabel?.text = model?.detail

            if let model = model {
                let textColor: UIColor
                switch model.titleStyle {
                case .default:
                    textColor = Styles.Colors.textColor
                case .tinted:
                    textColor = Styles.Colors.tintColor
                case .destructive:
                    textColor = Styles.Colors.redColor
                }
                textLabel?.textColor = textColor
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
