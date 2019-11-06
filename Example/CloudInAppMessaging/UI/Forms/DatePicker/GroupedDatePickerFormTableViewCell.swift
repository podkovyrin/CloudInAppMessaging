//
//  TextFieldFormTableViewCell.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 7/28/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

final class GroupedDatePickerFormTableViewCell: UITableViewCell, DatePickerFormTableViewCell {
    var model: DatePickerFormCellModel? {
        didSet {
            guard let model = model else { return }

            titleLabel.text = model.title

            textField.text = model.text
            textField.placeholder = model.placeholder

            textField.autocapitalizationType = model.autocapitalizationType
            textField.autocorrectionType = model.autocorrectionType
            textField.spellCheckingType = model.spellCheckingType
            textField.smartQuotesType = model.smartQuotesType
            textField.smartDashesType = model.smartDashesType
            textField.smartInsertDeleteType = model.smartInsertDeleteType
            textField.keyboardType = model.keyboardType
            textField.keyboardAppearance = model.keyboardAppearance
            textField.returnKeyType = model.returnKeyType
            textField.enablesReturnKeyAutomatically = model.enablesReturnKeyAutomatically
            textField.isSecureTextEntry = model.isSecureTextEntry
            textField.textContentType = model.textContentType

            textField.inputAccessoryView = model.showsInputAccessoryView ? inputAccessoryViewToolbar() : nil

            datePicker.timeZone = model.timeZone
            if let date = model.date {
                datePicker.date = date
            }
            datePicker.minimumDate = model.minDate
            datePicker.maximumDate = model.maxDate
        }
    }

    weak var delegate: TextInputFormTableViewCellDelegate?

    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let datePicker = UIDatePicker()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = Styles.Colors.textColor
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)

        textField.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            textField.backgroundColor = .secondarySystemGroupedBackground
        }
        textField.borderStyle = .roundedRect
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.delegate = self
        textField.textAlignment = .right
        contentView.addSubview(textField)

        datePicker.addTarget(self, action: #selector(datePickerValueDidChange), for: .valueChanged)
        textField.inputView = datePicker

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: Styles.Sizes.minPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                               constant: -Styles.Sizes.minPadding),

            textField.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: Styles.Sizes.minPadding),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Styles.Sizes.padding),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -Styles.Sizes.minPadding),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            textField.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textInputBecomeFirstResponder() {
        textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    @objc
    func textInputDoneAction() {
        delegate?.textInputFormTableViewCellNextResponderOrDone(self)
    }

    @objc
    private func datePickerValueDidChange() {
        model?.date = datePicker.date
        textField.text = model?.text
    }
}

extension GroupedDatePickerFormTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
}
