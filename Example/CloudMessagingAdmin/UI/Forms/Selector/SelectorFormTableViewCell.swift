//
//  SelectorFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

protocol SelectorFormTableViewCell where Self: UITableViewCell {
    var model: SelectorFormCellModel? { get set }
}
