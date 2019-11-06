//
//  ButtonFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/3/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class SelectorFormCellModel: TitledFormCellModel {
    var detail: String?
    var accessoryType = UITableViewCell.AccessoryType.none
    var isEnabled: Bool = true
    var action: (() -> Void)?
}
