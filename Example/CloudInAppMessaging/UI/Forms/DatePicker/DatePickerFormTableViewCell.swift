//
//  TextFieldFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

protocol DatePickerFormTableViewCell: TextInputFormTableViewCell {
    var model: DatePickerFormCellModel? { get set }
}
