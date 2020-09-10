//
//  Observable.swift
//  SimpleTwoWayBinding
//
//  Created by Manish Katoch on 11/26/17.
//

import Foundation
import UIKit

public protocol ObservableThing { }

public typealias ReceiptDisposer = [BindingReceipt]

extension ReceiptDisposer {
    public func dispose() {
        forEach { disposable in
            disposable.dispose()
        }
    }
}

public final class BindingReceipt: Hashable, Identifiable {
    public let id = UUID()
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: BindingReceipt, rhs: BindingReceipt) -> Bool { lhs.id == rhs.id }

    public var dispose: (() -> Void)!

    deinit {
        dispose()
    }

    public func add(to disposal: inout ReceiptDisposer) {
        disposal.append(self)
    }
}

public class Observable<ObservedType>: ObservableThing {
    public typealias Observer = (_ observable: Observable<ObservedType>, ObservedType) -> Void
    
    /// Map of receipt objects to the binding blocks those objects represent; see bind(observer:) and unbind(:)
    private var observers: [BindingReceipt: Observer] = [:]
    /// Map of other observers we've been bound to; see map(:) & other functional conveniences. This allows us to hold strong references to the anonymous observables generated in a chained series of calls, and break them when needed.
    private var bindings: [BindingReceipt: () -> Void] = [:]
    
    internal var paused: Bool = false
    
    public var value: ObservedType? {
        didSet { fire() }
    }
    
    /// Notify all observers with the current value if non-nil.
    public func fire() {
        if let value = value {
            notifyObservers(value)
        }
    }

    fileprivate var _onDispose: () -> Void
    
    public init(_ value: ObservedType? = nil, onDispose: @escaping () -> Void = {}) {
        self.value = value
        self._onDispose = onDispose
    }
    
    @discardableResult
    public func bind(observer: @escaping Observer) -> BindingReceipt {
        let r = BindingReceipt()

        r.dispose = { [weak self] in
            self?.observers[r] = nil
            self?.bindings[r] = nil
            self?._onDispose()
        }

        observers[r] = observer
        return r
    }
    
    public func setObserving(_ referenceHolder: @escaping () -> Void, receipt: BindingReceipt) {
        bindings[receipt] = referenceHolder
    }
    
    public func unbind(_ r: BindingReceipt) {
        guard observers[r] != nil else {
            print("Warning: attempted to unbind with an invalid receipt")
            return
        }
        observers[r] = nil
        bindings[r] = nil
    }
    
    internal func notifyObservers(_ value: ObservedType) {
        observers.values.forEach { [unowned self] observer in
            guard paused == false else { return }
            observer(self, value)
        }
    }
    
    
    
}

