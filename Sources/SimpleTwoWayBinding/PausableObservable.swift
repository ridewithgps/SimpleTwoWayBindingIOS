//
//  PausableObservable.swift
//  Pods-SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 6/15/20.
//

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

public struct PausableReceipt {
    public let receipt: BindingReceipt
    
    public var unbind: (BindingReceipt) -> Void
    public var pauseObservations: () -> Void
    public var unpauseObservations: () -> Void
     
    public func add(to bag: ReceiptBag) { bag.receipts.append(self) }
}

extension Observable {
    public func pauseObservations() { paused = true }
    public func unpauseObservations() {
        paused = false
        if let value = value {
            notifyObservers(value)
        }
    }
    
    public func pausableBind(observer: @escaping Observer) -> PausableReceipt {
        PausableReceipt(
            receipt: bind(observer: observer),
            unbind: unbind,
            pauseObservations: pauseObservations,
            unpauseObservations: unpauseObservations)
    }
    
    public func pausableBind(replay: Bool = true, on queue: DispatchQueue? = nil, _ f: @escaping (ObservedType) -> Void) -> PausableReceipt {
        PausableReceipt(
            receipt: bind(replay: replay, on: queue, f),
            unbind: unbind,
            pauseObservations: pauseObservations,
            unpauseObservations: unpauseObservations
        )
    }
    
    public func pausableBind<Root: AnyObject>(replay: Bool = true, on queue: DispatchQueue? = nil, _ target: inout Root, _ path: WritableKeyPath<Root, ObservedType>) -> PausableReceipt {
        pausableBind(replay: replay, on: queue) { [weak target] value in target?[keyPath: path] = value }
    }
}
