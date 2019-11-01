//
//  GroupedSwitcherFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

class GroupedSwitcherFormTableViewCell: UITableViewCell, SwitcherFormTableViewCell {
    var model: SwitcherFormCellModel? {
        didSet {
            model?.changesObserver = self
            textLabel?.text = model?.title
            switcher?.isOn = model?.isOn ?? false

            if let model = model {
                textLabel?.textColor = model.titleStyle == .default ? Styles.Colors.textColor : Styles.Colors.tintColor
            }
        }
    }

    private var switcher: UISwitch? {
        return accessoryView as? UISwitch
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        let switcher = UISwitch()
        switcher.onTintColor = Styles.Colors.tintColor
        switcher.addTarget(self, action: #selector(switcherAction), for: .valueChanged)
        switcher.sizeToFit()
        accessoryView = switcher
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions

    @objc
    private func switcherAction() {
        guard let model = model else {
            return
        }

        model.isOn = !model.isOn
        model.action?(model)
    }
}

extension GroupedSwitcherFormTableViewCell: SwitcherFormCellModelChangesObserver {
    func switcherFormCellModelDidChangeIsOn(_ model: SwitcherFormCellModel) {
        switcher?.setOn(model.isOn, animated: true)
    }
}
