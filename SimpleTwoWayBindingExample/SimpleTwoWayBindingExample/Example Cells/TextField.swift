//
//  TextField.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding
import UIKit

class TextFieldCell: UITableViewCell {
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.accessibilityIdentifier = "textField"
        tf.text = "This is a text field"
        tf.font = .preferredFont(forTextStyle: .body)
        tf.delegate = self
        return tf
    }()
    
    lazy var infoLabel: UILabel = {
        let l = label("Information about this text field's contents", testID: "textFieldInformation")
        l.font = .preferredFont(forTextStyle: .footnote)
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = vstackOf([textField, infoLabel])
        
        contentView.addSubview(stack)
        constrain(stack, toEdgesOf: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextFieldCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TextFieldCell: CellInformation {
    static var reuseIdentifier: String { "textField" }
    static var cellHeight: CGFloat { 70 }
}

extension TextFieldCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        textField.bind(with: viewModel.userEnteredText)
        infoLabel.bind(with: viewModel.processedText)
    }
}
