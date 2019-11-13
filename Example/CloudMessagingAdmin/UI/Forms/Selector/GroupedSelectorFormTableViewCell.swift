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

final class GroupedSelectorFormTableViewCell: UITableViewCell, SelectorFormTableViewCell {
    var model: SelectorFormCellModel? {
        didSet {
            textLabel?.text = model?.title
            detailTextLabel?.text = model?.detail

            if let model = model {
                let textColor: UIColor
                switch model.titleStyle {
                case .default:
                    textColor = Styles.Colors.textColor
                case .tinted:
                    textColor = Styles.Colors.tintColor
                case .destructive:
                    textColor = Styles.Colors.redColor
                }
                textLabel?.textColor = textColor
                selectionStyle = model.isEnabled ? .default : .none
                accessoryType = model.accessoryType
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
