//
//  SwitcherFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import Foundation

protocol SwitcherFormCellModelChangesObserver: AnyObject {
    func switcherFormCellModelDidChangeIsOn(_ model: SwitcherFormCellModel)
}

final class SwitcherFormCellModel: TitledFormCellModel {
    var isOn: Bool = false {
        didSet {
            changesObserver?.switcherFormCellModelDidChangeIsOn(self)
        }
    }

    var action: ((SwitcherFormCellModel) -> Void)?
    internal weak var changesObserver: SwitcherFormCellModelChangesObserver?
}
