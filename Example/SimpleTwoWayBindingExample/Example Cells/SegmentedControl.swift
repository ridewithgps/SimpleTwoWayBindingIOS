//
//  SegmentedControl.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding
import UIKit

class SegmentedControlCell: UITableViewCell {
    lazy var segmentedControl: UISegmentedControl = {
        let s = UISegmentedControl()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.accessibilityIdentifier = "segmentedControl"
        S2WBExampleViewModel.segmentImageNames
            .map(UIImage.init(systemName:))
            .enumerated()
            .forEach { s.insertSegment(with: $1, at: $0, animated: false) }
        return s
    }()
    
    lazy var info: UILabel = {
        let l = label("This is a segmented control", testID: "segmentedControlInformation")
        l.font = .preferredFont(forTextStyle: .footnote)
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = vstackOf([segmentedControl, info])
        contentView.addSubview(stack)
        constrain(stack, toEdgesOf: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SegmentedControlCell: CellInformation {
    static var reuseIdentifier: String { "segmentCell" }
    static var cellHeight: CGFloat { 80 }
}

extension SegmentedControlCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        segmentedControl.bind(with: viewModel.selectedSegment)
        info.bind(with: viewModel.segmentDescription)
    }
}
