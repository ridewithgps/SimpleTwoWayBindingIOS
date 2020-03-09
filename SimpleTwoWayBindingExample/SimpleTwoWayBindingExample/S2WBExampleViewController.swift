//
//  ViewController.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/4/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import SimpleTwoWayBinding
import UIKit

struct S2WBExampleViewModel {
    let turnOn: Observable<Bool> = Observable()
    let turnOnDescription: Observable<String>
    
    init() {
        turnOnDescription = turnOn
            .map { on -> String in
                if on { return "The switch is on" }
                else { return "The switch is off" }
            }
    }
}

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
        
        var associatedClass: AnyClass {
            switch self {
            case .switch: return SwitchCell.self
            }
        }
        
        var reuseIdentifier: String {
            switch self {
            case .switch: return SwitchCell.reuseIdentifier
            }
        }
        
        var height: CGFloat {
            switch self {
            case .switch: return SwitchCell.cellHeight
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.allCases[indexPath.row].reuseIdentifier, for: indexPath)
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

func label(_ s: String, testID: String) -> UILabel {
    let l = UILabel()
    l.translatesAutoresizingMaskIntoConstraints = false
    l.text = s
    l.font = .preferredFont(forTextStyle: .headline)
    l.numberOfLines = 0
    l.accessibilityIdentifier = testID
    return l
}

class SwitchCell: UITableViewCell {
    var viewModel: S2WBExampleViewModel?
    
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
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            contentView.rightAnchor.constraint(equalToSystemSpacingAfter: stack.rightAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: stack.bottomAnchor, multiplier: 1),
            stack.leftAnchor.constraint(equalToSystemSpacingAfter: contentView.leftAnchor, multiplier: 1)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SwitchCell: CellInformation {
    static var reuseIdentifier: String { "switchCell" }
    static var cellHeight: CGFloat { 60 }
}

extension SwitchCell: ViewModelBindable {
    func bind(to viewModel: S2WBExampleViewModel) {
        self.aSwitch.bind(with: viewModel.turnOn)
        self.switchLabel.bind(with: viewModel.turnOnDescription)
    }
}
