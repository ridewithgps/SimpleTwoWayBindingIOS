//
//  Bindable.swift
//  SimpleTwoWayBinding
//
//  Created by Manish Katoch on 11/26/17.
//

import Foundation
import UIKit

public protocol Bindable: NSObjectProtocol {
    associatedtype BindingType: Equatable
    func observingValue() -> BindingType?
    func updateValue(with value: BindingType)
    func bind(with observable: Observable<BindingType>) -> BindingReceipt
}

fileprivate struct AssociatedKeys {
    static var binder: UInt8 = 0
}

extension Bindable where Self: NSObject {

    private var binder: Observable<BindingType> {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.binder) as? Observable<BindingType> else {
                let newValue = Observable<BindingType>()
                objc_setAssociatedObject(self, &AssociatedKeys.binder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newValue
            }
            return value
        }
        set(newValue) {
             objc_setAssociatedObject(self, &AssociatedKeys.binder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func getBinderValue() -> BindingType? {
        return binder.value
    }
    
    public func setBinderValue(with value: BindingType?) {
        binder.value = value
    }
    
    public func register(for observable: Observable<BindingType>) {
        binder = observable
    }
    
    func valueChanged() {
        if binder.value != self.observingValue() {
            setBinderValue(with: self.observingValue())
        }
    }

    @discardableResult
    public func bind(with observable: Observable<BindingType>) -> BindingReceipt {

        if self is UIControl {
            let sleeve = ActionClosure {
                [weak self] in
                self?.valueChanged()
            }

            (self as! UIControl).addTarget(sleeve, action: #selector(ActionClosure.invoke), for: [.valueChanged, .editingChanged])

            objc_setAssociatedObject(self, memoryAddress, sleeve, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        self.binder = observable
        if let val = observable.value {
            self.updateValue(with: val)
        }

        return self.observe(for: observable) { (value) in
            self.updateValue(with: value)
        }
    }    
}


extension NSObject {
    fileprivate var memoryAddress: String {
        String(format: "%p", unsafeBitCast(self, to: UInt.self))
    }

    @objc fileprivate final class ActionClosure: NSObject {
        let closure: () -> Void

        init(_ closure: @escaping () -> Void) {
            self.closure = closure
        }

        @objc func invoke() {
            closure()
        }
    }
}
