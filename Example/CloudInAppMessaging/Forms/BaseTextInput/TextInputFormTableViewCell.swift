//
//  TextFieldFormCellModel.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 8/19/19.
//  Copyright © 2019 2FAuth. All rights reserved.
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
