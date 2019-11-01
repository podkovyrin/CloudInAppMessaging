//
//  FormSectionModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/3/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import Foundation

final class FormSectionModel {
    let items: [FormCellModel]
    var header: String?
    var footer: String?

    init(_ items: [FormCellModel]) {
        self.items = items
    }
}
