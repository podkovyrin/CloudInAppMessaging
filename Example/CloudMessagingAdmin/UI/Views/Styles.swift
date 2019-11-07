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

// swiftlint:disable force_unwrapping

enum Styles {
    enum Colors {
        static let tintColor = UIColor(named: "TintColor")!
        static var textColor: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor.label
            }
            else {
                return UIColor.black
            }
        }

        static let redColor = UIColor.systemRed
    }

    enum Sizes {
        static let minPadding: CGFloat = 8.0
        static let padding: CGFloat = 16.0
    }
}
