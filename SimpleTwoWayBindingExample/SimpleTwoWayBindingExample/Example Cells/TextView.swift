//
//  TextView.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding
import UIKit

class TextViewCell: UITableViewCell {
    lazy var textView: BindableTextView = {
        let t = BindableTextView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.accessibilityIdentifier = "textView"
        t.font = .preferredFont(forTextStyle: .body)
        t.text = "This is a text field whose contents are bound to the other controls in this example app."
        return t
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        constrain(textView, toEdgesOf: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextViewCell: CellInformation {
    static var reuseIdentifier: String { "textViewCell" }
    static var cellHeight: CGFloat { 200 }
}

extension TextViewCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        textView.bind(with: viewModel.textViewContents)
    }
}
