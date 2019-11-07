//
//  TextFieldFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 7/28/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class DatePickerFormCellModel: TextInputFormCellModel {
    var date: Date? {
        didSet {
            didChangeDate?(self)
        }
    }

    var minDate: Date?
    var maxDate: Date?

    // swiftlint:disable force_unwrapping
    var timeZone = TimeZone(secondsFromGMT: 0)! {
        didSet {
            formatter.timeZone = timeZone
        }
    }

    // swiftlint:enable force_unwrapping

    var placeholder: String?

    var didChangeDate: ((DatePickerFormCellModel) -> Void)?

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = timeZone
        return formatter
    }()

    override var text: String? {
        get {
            if let date = date {
                return formatter.string(from: date)
            }
            else {
                return nil
            }
        }
        // swiftlint:disable unused_setter_value
        set {}
        // swiftlint:enable unused_setter_value
    }
}
