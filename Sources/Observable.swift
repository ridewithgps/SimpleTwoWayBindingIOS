//
//  Observable.swift
//  SimpleTwoWayBinding
//
//  Created by Manish Katoch on 11/26/17.
//

import Foundation
import UIKit

/// A helper class to manage pausable receipts
public class ReceiptBag {
    public var receipts: [PausableReceipt] = []
    
    /// Pause observations in all receipts we're holding
    public func pause() { receipts.forEach { $0.pauseObservations() } }
    
    /// Unpause observations in all receipts we're holding
    public func unpause() { receipts.forEach { $0.unpauseObservations() } }
    
    private var handleBackgroundNotifications = true
    private var observers: [NSObjectProtocol] = []
    
    /// - Parameter handleBackgroundNotifications: When true, this bag will automatically sign up for iOS background/foreground notifications; when those are triggered, the bag's receipts will be paused and unpaused
    public init(handleBackgroundNotifications: Bool = true) {
        self.handleBackgroundNotifications = handleBackgroundNotifications
        
        if handleBackgroundNotifications {
            observers = [
                NotificationCenter.default.addObserver(
                    forName: UIApplication.didEnterBackgroundNotification,
                    object: nil, queue: nil
                ) { [weak self] _ in self?.pause() },
                NotificationCenter.default.addObserver(
                    forName: UIApplication.didBecomeActiveNotification,
                    object: nil, queue: nil
                ) { [weak self] _ in self?.unpause() }
            ]
        }
    }
    
    deinit { observers.forEach(NotificationCenter.default.removeObserver) }
}

public struct BindingReceipt: Hashable, Identifiable {
    public let id = UUID()
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: BindingReceipt, rhs: BindingReceipt) -> Bool { lhs.id == rhs.id }
}

public struct PausableReceipt {
    public let receipt: BindingReceipt
    
    public var unbind: (BindingReceipt) -> Void
    public var pauseObservations: () -> Void
    public var unpauseObservations: () -> Void
     
    public func add(to bag: ReceiptBag) { bag.receipts.append(self) }
}

public class Observable<ObservedType> {
    public typealias Observer = (_ observable: Observable<ObservedType>, ObservedType) -> Void
    
    /// Map of receipt objects to the binding blocks those objects represent; see bind(observer:) and unbind(:)
    private var observers: [BindingReceipt: Observer] = [:]
    /// Map of other observers we've been bound to; see map(:) & other functional conveniences. This allows us to hold strong references to the anonymous observables generated in a chained series of calls, and break them when needed.
    private var bindings: [BindingReceipt: () -> Void] = [:]
    
    public var value: ObservedType? {
        didSet {
            if let value = value {
                notifyObservers(value)
            }
        }
    }
    
    public init(_ value: ObservedType? = nil) {
        self.value = value
    }
    
    @discardableResult
    public func bind(observer: @escaping Observer) -> BindingReceipt {
        let r = BindingReceipt()
        observers[r] = observer
        return r
    }
    
    public func pausableBind(observer: @escaping Observer) -> PausableReceipt {
        PausableReceipt(
            receipt: bind(observer: observer),
            unbind: unbind,
            pauseObservations: pauseObservations,
            unpauseObservations: unpauseObservations)
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
    
    private func notifyObservers(_ value: ObservedType) {
        observers.values.forEach { [unowned self] observer in
            guard paused == false else { return }
            observer(self, value)
        }
    }
    
    private var paused: Bool = false
    
    public func pauseObservations() { paused = true }
    public func unpauseObservations() { paused = false }
}

