//
//  SwitcherFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

protocol SwitcherFormTableViewCell where Self: UITableViewCell {
    var model: SwitcherFormCellModel? { get set }
}
