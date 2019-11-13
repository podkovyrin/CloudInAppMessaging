//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
