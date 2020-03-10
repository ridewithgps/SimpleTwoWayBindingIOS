//
//  Switch.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding
import UIKit

class SwitchCell: UITableViewCell {
    lazy var aSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.accessibilityIdentifier = "switch"
        return s
    }()
    
    lazy var switchLabel: UILabel = {
        label("This is a switch.", testID: "switchLabel")
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = hstackOf([
            aSwitch,
            switchLabel
        ])
        contentView.addSubview(stack)
        constrain(stack, toEdgesOf: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SwitchCell: CellInformation {
    static var reuseIdentifier: String { "switchCell" }
    static var cellHeight: CGFloat { 80 }
}

extension SwitchCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        self.aSwitch.bind(with: viewModel.turnOn)
        self.switchLabel.bind(with: viewModel.turnOnDescription)
    }
}
