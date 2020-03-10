//
//  Slider.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding
import UIKit

class SliderCell: UITableViewCell {
    lazy var slider: UISlider = {
        let s = UISlider()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.accessibilityIdentifier = "slider"
        return s
    }()
    
    lazy var info: UILabel = {
        let l = label("This is a slider", testID: "sliderInformation")
        l.font = .preferredFont(forTextStyle: .footnote)
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stack = vstackOf([slider, info])
        contentView.addSubview(stack)
        constrain(stack, toEdgesOf: contentView)
        NSLayoutConstraint.activate([
            slider.leftAnchor.constraint(equalToSystemSpacingAfter: contentView.leftAnchor, multiplier: 1),
            contentView.rightAnchor.constraint(equalToSystemSpacingAfter: slider.rightAnchor, multiplier: 1)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderCell: CellInformation {
    static var reuseIdentifier: String { "slider" }
    static var cellHeight: CGFloat { 90 }
}

extension SliderCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        slider.bind(with: viewModel.sliderPosition)
        info.bind(with: viewModel.sliderDescription)
    }
}
