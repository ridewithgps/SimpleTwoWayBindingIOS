//
//  Stepper.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding
import UIKit

class StepperCell: UITableViewCell {
    lazy var stepper: UIStepper = {
        let s = UIStepper()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.accessibilityIdentifier = "stepper"
        s.setIncrementImage(UIImage(systemName: "plus.circle"), for: .normal)
        s.setDecrementImage(UIImage(systemName: "minus.circle"), for: .normal)
        s.value = 0
        s.minimumValue = 0
        s.maximumValue = 10
        s.stepValue = 1
        return s
    }()
    
    lazy var info: UILabel = {
        label("This is a stepper control", testID: "stepperInformation")
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stack = hstackOf([stepper, info])
        contentView.addSubview(stack)
        constrain(stack, toEdgesOf: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StepperCell: CellInformation {
    static var reuseIdentifier: String { "stepperCell" }
    static var cellHeight: CGFloat { 80 }
}

extension StepperCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        stepper.bind(with: viewModel.stepperPosition)
        info.bind(with: viewModel.stepperDescription)
    }
}
