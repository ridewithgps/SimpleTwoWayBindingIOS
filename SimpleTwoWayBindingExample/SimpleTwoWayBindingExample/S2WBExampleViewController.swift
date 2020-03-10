//
//  ViewController.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/4/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import UIKit

class S2WBExampleViewController: UITableViewController {
    let viewModel = S2WBExampleViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Cells.allCases.forEach { cellInfo in
            self.tableView.register(cellInfo.associatedClass, forCellReuseIdentifier: cellInfo.reuseIdentifier)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { Cells.allCases.count }
    
    enum Cells: CaseIterable {
        case `switch`
        case textField
        case slider
        case stepper
        case segment
        case textView
        
        var associatedClass: AnyClass {
            switch self {
            case .switch: return SwitchCell.self
            case .textField: return TextFieldCell.self
            case .slider: return SliderCell.self
            case .stepper: return StepperCell.self
            case .segment: return SegmentedControlCell.self
            case .textView: return TextViewCell.self
            }
        }
        
        var reuseIdentifier: String {
            switch self {
            case .switch: return SwitchCell.reuseIdentifier
            case .textField: return TextFieldCell.reuseIdentifier
            case .slider: return SliderCell.reuseIdentifier
            case .stepper: return StepperCell.reuseIdentifier
            case .segment: return SegmentedControlCell.reuseIdentifier
            case .textView: return TextViewCell.reuseIdentifier
            }
        }
        
        var height: CGFloat {
            switch self {
            case .switch: return SwitchCell.cellHeight
            case .textField: return TextFieldCell.cellHeight
            case .slider: return SliderCell.cellHeight
            case .stepper: return StepperCell.cellHeight
            case .segment: return SegmentedControlCell.cellHeight
            case .textView: return TextViewCell.cellHeight
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.allCases[indexPath.row].reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        guard let bindable = cell as? ViewModelBindable else {
            return cell
        }
        bindable.bind(to: viewModel)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Cells.allCases[indexPath.row].height
    }
}

protocol CellInformation {
    static var reuseIdentifier: String { get }
    static var cellHeight: CGFloat { get }
}

protocol ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel)
}

func hstackOf(_ views: [UIView]) -> UIStackView {
    let s = UIStackView(arrangedSubviews: views)
    s.translatesAutoresizingMaskIntoConstraints = false
    s.axis = .horizontal
    s.alignment = .center
    return s
}

func vstackOf(_ views: [UIView]) -> UIStackView {
    let s = UIStackView(arrangedSubviews: views)
    s.translatesAutoresizingMaskIntoConstraints = false
    s.axis = .vertical
    s.alignment = .leading
    return s
}

func label(_ s: String, testID: String) -> UILabel {
    let l = UILabel()
    l.translatesAutoresizingMaskIntoConstraints = false
    l.text = s
    l.font = .preferredFont(forTextStyle: .headline)
    l.numberOfLines = 0
    l.accessibilityIdentifier = testID
    return l
}

func constrain(_ child: UIView, toEdgesOf parent: UIView) {
    NSLayoutConstraint.activate([
        child.topAnchor.constraint(equalToSystemSpacingBelow: parent.topAnchor, multiplier: 1),
        parent.rightAnchor.constraint(equalToSystemSpacingAfter: child.rightAnchor, multiplier: 1),
        parent.bottomAnchor.constraint(equalToSystemSpacingBelow: child.bottomAnchor, multiplier: 1),
        child.leftAnchor.constraint(equalToSystemSpacingAfter: parent.leftAnchor, multiplier: 1)
    ])
}
