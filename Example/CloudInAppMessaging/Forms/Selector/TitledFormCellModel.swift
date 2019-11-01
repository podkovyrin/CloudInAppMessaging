//
//  TitledFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/22/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import Foundation

enum TitleStyle {
    case `default`
    case tinted
}

class TitledFormCellModel: FormCellModel {
    var title: String?
    var titleStyle = TitleStyle.default
}
