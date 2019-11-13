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

@objc protocol TextInputFormTableViewCellDelegate: AnyObject {
    func textInputFormTableViewCellNextResponderOrDone(_ cell: TextInputFormTableViewCell)
}

@objc protocol TextInputFormTableViewCell where Self: UITableViewCell {
    var delegate: TextInputFormTableViewCellDelegate? { get set }

    func textInputBecomeFirstResponder()
    func textInputDoneAction()
}

extension TextInputFormTableViewCell {
    func inputAccessoryViewToolbar() -> UIToolbar {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                         target: self,
                                         action: #selector(resignFirstResponder))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done,
                                       target: self,
                                       action: #selector(textInputDoneAction))

        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: contentView.bounds.width, height: 44.0))
        toolbar.items = [cancelItem, spaceItem, doneItem]

        return toolbar
    }
}
