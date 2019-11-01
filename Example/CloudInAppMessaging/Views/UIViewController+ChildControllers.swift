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

extension UIViewController {
    func displayController(_ controller: UIViewController, inContentView contentView: UIView) {
        guard let childView = controller.view else {
            return
        }

        childView.translatesAutoresizingMaskIntoConstraints = false

        addChild(controller)
        contentView.addSubview(childView)

        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: contentView.topAnchor),
            childView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            childView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            childView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        controller.didMove(toParent: self)
    }
}
