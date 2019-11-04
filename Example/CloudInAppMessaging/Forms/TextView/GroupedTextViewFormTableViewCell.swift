//
//  TextFieldFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 7/28/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class GroupedTextViewFormTableViewCell: UITableViewCell, TextViewFormTableViewCell {
    var model: TextViewFormCellModel? {
        didSet {
            guard let model = model else { return }

            titleLabel.text = model.title

            textView.text = model.text
            textView.placeholderText = model.placeholder

            textView.autocapitalizationType = model.autocapitalizationType
            textView.autocorrectionType = model.autocorrectionType
            textView.spellCheckingType = model.spellCheckingType
            if #available(iOS 11.0, *) {
                textView.smartQuotesType = model.smartQuotesType
                textView.smartDashesType = model.smartDashesType
                textView.smartInsertDeleteType = model.smartInsertDeleteType
            }
            textView.keyboardType = model.keyboardType
            textView.keyboardAppearance = model.keyboardAppearance
            textView.returnKeyType = model.returnKeyType
            textView.enablesReturnKeyAutomatically = model.enablesReturnKeyAutomatically
            textView.isSecureTextEntry = model.isSecureTextEntry
            textView.textContentType = model.textContentType

            textView.inputAccessoryView = model.showsInputAccessoryView ? inputAccessoryViewToolbar() : nil
        }
    }

    weak var delegate: TextInputFormTableViewCellDelegate?

    private let titleLabel = UILabel(frame: .zero)
    private let textView = PlaceholderTextView(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = Styles.Colors.textColor
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        contentView.addSubview(titleLabel)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.delegate = self
        textView.textColor = Styles.Colors.textColor
        if #available(iOS 13.0, *) {
            textView.layer.borderColor = UIColor.separator.cgColor
        }
        else {
            textView.layer.borderColor = UIColor.lightGray.cgColor
        }
        textView.layer.borderWidth = 1.0 / UIScreen.main.scale
        textView.layer.cornerRadius = 4.0
        textView.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            textView.backgroundColor = .secondarySystemGroupedBackground
        }
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: Styles.Sizes.minPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Styles.Sizes.minPadding),
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                             constant: -Styles.Sizes.minPadding),
            textView.heightAnchor.constraint(equalToConstant: 64.0),
        ])
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textInputBecomeFirstResponder() {
        textView.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    @objc
    func textInputDoneAction() {
        delegate?.textInputFormTableViewCellNextResponderOrDone(self)
    }
}

extension GroupedTextViewFormTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nsStringText = textView.text as NSString?
        model?.text = nsStringText?.replacingCharacters(in: range, with: text) as String? ?? ""

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        model?.text = textView.text
    }
}
