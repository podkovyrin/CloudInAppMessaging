//
//  TextFieldFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 7/28/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class TextFieldFormCellModel: TextInputFormCellModel {
    var placeholder: String?

    var validateAction: ((String) -> Bool)?
    var transformAction: ((String) -> String?)?
}
