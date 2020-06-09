//
//  Observable+FunctionalConvenience.swift
//  Ride With GPS
//
//  Created by Ryan Forsythe on 2/27/20.
//  Copyright © 2020 Ride with GPS. All rights reserved.
//

import Foundation

public extension Observable {
    /// Bind to this observable with a simple value function, optionally replaying the existing value into the stream immediately
    ///
    /// This is a nice alternative to the standard `bind((Observable<ObservedType>, ObservedType)->Void)`, since we're 99% of the time uninterested in getting a reference to the Observable itself.
    /// - Parameters:
    ///   - replay: If there's a value in this observable, after setting up the binding immediately fire the observation function with that value, rather than the default behavior of waiting for a new value to come into the stream. Defaults to true.
    ///   - f: an observation function
    @discardableResult
    func bind(replay: Bool = true, _ f: @escaping (ObservedType) -> Void) -> BindingReceipt {
        let r = bind { _, value in f(value) }
        if replay, let value = value {
            f(value)
        }
        return r
    }
    
    func pausableBind(replay: Bool = true, _ f: @escaping (ObservedType) -> Void) -> PausableReceipt {
        PausableReceipt(
            receipt: bind(replay: replay, f),
            unbind: unbind,
            pauseObservations: pauseObservations,
            unpauseObservations: unpauseObservations
        )
    }
    
    @discardableResult
    func bindUI(replay: Bool = true, _ f: @escaping (ObservedType) -> Void) -> BindingReceipt {
        let r: BindingReceipt = bind { _, value in
            DispatchQueue.main.async {
                f(value)
            }
        }
        if replay, let value = value {
            DispatchQueue.main.async {
                f(value)
            }
        }
        return r
    }
    
    func pausableBindUI(replay: Bool = true, _ f: @escaping (ObservedType) -> Void) -> PausableReceipt {
        PausableReceipt(
            receipt: bindUI(replay: replay, f),
            unbind: unbind,
            pauseObservations: pauseObservations,
            unpauseObservations: unpauseObservations
        )
    }
    
    /// Create a new observable whose value is mapped from this observable's values
    /// - Parameters:
    ///   - replay: If there's a value in this observable, after setting up the binding immediately fire the observation function with that value, rather than the default behavior of waiting for a new value to come into the stream. Defaults to true.
    ///   - f: mapping function from this observable's values to the new observable's values
    func map<A>(replay: Bool = true, _ f: @escaping (ObservedType) -> A) -> Observable<A> {
        let child = Observable<A>()
        let r: BindingReceipt = bind(replay: replay) { [weak child] value in
            child?.value = f(value)
        }
        child.setObserving({ _ = self }, receipt: r)
        return child
    }
    
    /// Create a new observable of the same type as this observable, whose value is filtered before delivery
    /// - Parameters:
    ///   - replay: If there's a value in this observable, after setting up the binding immediately fire the observation function with that value, rather than the default behavior of waiting for a new value to come into the stream. Defaults to true.
    ///   - f: filter function on this observable's values
    func filter(replay: Bool = true, _ f: @escaping (ObservedType) -> Bool) -> Observable<ObservedType> {
        let child = Observable<ObservedType>()
        let r: BindingReceipt = bind(replay: replay) { [weak child] value in
            if f(value) {
                child?.value = value
            }
        }
        child.setObserving({ _ = self }, receipt: r)
        return child
    }
    
    /// Create a new observable whose value is defined by integrating this observable's value with the new observable's value using the `reducer` function
    /// - Parameters:
    ///   - replay: If there's a value in this observable, after setting up the binding immediately fire the observation function with that value, rather than the default behavior of waiting for a new value to come into the stream. Defaults to true.
    ///   - initial: initial value for the reducer function, when the new observable is empty
    ///   - reducer: reducer function to integrate our new value with the new observable's value
    func reduce<A>(replay: Bool = true, initial: A, _ reducer: @escaping (A, ObservedType) -> A) -> Observable<A> {
        let child = Observable<A>()
        let r: BindingReceipt = bind(replay: replay) { [weak child] newValue in
            let oldValue = child?.value ?? initial
            child?.value = reducer(oldValue, newValue)
        }
        child.setObserving({ _ = self }, receipt: r)
        return child
    }
    
    func debug(_ message: String) -> Observable {
        map { value in
            print(message + " (Current value: \(value))")
            return value
        }
    }
    
    /// Creates a new observable whose value is mapped from this observable's values, unless the mapping function returns nil
    /// - Parameters:
    ///   - replay: If there's a value in this observable, after setting up the binding immediately fire the observation function with that value, rather than the default behavior of waiting for a new value to come into the stream. Defaults to true.
    ///   - f: mapping function from this observable's values to an optional of the new observable's values.
    func compactMap<A>(replay: Bool = true, _ f: @escaping (ObservedType) -> A?) -> Observable<A> {
        let child = Observable<A>()
        let r: BindingReceipt = bind(replay: replay) { [weak child] value in
            if let v = f(value) {
                child?.value = v
            }
        }
        child.setObserving({ _ = self }, receipt: r)
        return child
    }
}

public extension Observable where ObservedType: Equatable {
    /// Only emit values when they differ from the previous value in this observable.
    /// - Parameter replay: If there's a value in this observable, after setting up the binding immediately fire the observation function with that value, rather than the default behavior of waiting for a new value to come into the stream. Defaults to true.
    func distinct(replay: Bool = true) -> Observable<ObservedType> {
        let child = Observable<ObservedType>()
        let r: BindingReceipt = bind(replay: replay) { [weak child] newValue in
            if newValue != child?.value {
                child?.value = newValue
            }
        }
        child.setObserving({ _ = self }, receipt: r)
        return child
    }
}


let ObserverZipThread = DispatchQueue(label: "RWGPS.Observer.Zipping")

private class Zip2Observable<A, B>: Observable<(A?, B?)> {
    weak var a: Observable<A>?
    weak var b: Observable<B>?
    
    init(_ a: Observable<A>, _ b: Observable<B>) {
        self.a = a
        self.b = b
        
        super.init()
        let ra = a.bind(replay: false) { [weak self] a in
            self?.value = (a, self?.b?.value)
        }
        let rb = b.bind(replay: false) { [weak self] b in
            self?.value = (self?.a?.value, b)
        }
        setObserving({ _ = a }, receipt: ra)
        setObserving({ _ = b }, receipt: rb)
        if let v = a.value {
            a.value = v
        } else if let v = b.value {
            b.value = v
        }
    }
}

/// Given two observables, create a new observable that produces a tuple of the two observers' current values any time either emits a value
public func zip<A, B>(_ a: Observable<A>, _ b: Observable<B>) -> Observable<(A?, B?)> { Zip2Observable(a, b) }

private class Zip3Observable<A, B, C>: Observable<(A?, B?, C?)> {
    weak var ab: Zip2Observable<A, B>?
    weak var c: Observable<C>?
    
    init(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>) {
        let ab = Zip2Observable(a, b)
        self.ab = ab
        self.c = c
        
        super.init()
        let rab = ab.bind(replay: false) { [weak self] ab in
            self?.value = (ab.0, ab.1, self?.c?.value)
        }
        let rc = c.bind(replay: false) { [weak self] c in
            self?.value = (self?.ab?.value?.0, self?.ab?.value?.1, c)
        }
        setObserving({ _ = ab }, receipt: rab)
        setObserving({ _ = b }, receipt: rc)
        if let v = a.value {
            a.value = v
        } else if let v = b.value {
            b.value = v
        } else if let v = c.value {
            c.value = v
        }
    }
}

public func zip<A, B, C>(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>) -> Observable<(A?, B?, C?)> { Zip3Observable(a, b, c) }

private class Zip4Observable<A, B, C, D>: Observable<(A?, B?, C?, D?)> {
    weak var abc: Zip3Observable<A, B, C>?
    weak var d: Observable<D>?
    
    init(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>, _ d: Observable<D>) {
        let abc = Zip3Observable(a, b, c)
        self.abc = abc
        self.d = d
        
        super.init()
        let rabc = abc.bind(replay: false) { [weak self] abc in
            self?.value = (abc.0, abc.1, abc.2, self?.d?.value)
        }
        let rd = d.bind(replay: false) { [weak self] d in
            self?.value = (self?.abc?.value?.0, self?.abc?.value?.1, self?.abc?.value?.2, d)
        }
        setObserving({ _ = abc }, receipt: rabc)
        setObserving({ _ = d }, receipt: rd)
        if let v = a.value {
            a.value = v
        } else if let v = b.value {
            b.value = v
        } else if let v = c.value {
            c.value = v
        } else if let v = d.value {
            d.value = v
        }
    }
}

public func zip<A, B, C, D>(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>, _ d: Observable<D>) -> Observable<(A?, B?, C?, D?)> { Zip4Observable(a, b, c, d) }

private class Zip5Observable<A, B, C, D, E>: Observable<(A?, B?, C?, D?, E?)> {
    weak var abcd: Zip4Observable<A, B, C, D>?
    weak var e: Observable<E>?
    
    init(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>, _ d: Observable<D>, _ e: Observable<E>) {
        let abcd = Zip4Observable(a, b, c, d)
        self.abcd = abcd
        self.e = e
        
        super.init()
        let rabcd = abcd.bind(replay: false) { [weak self] abcd in
            self?.value = (abcd.0, abcd.1, abcd.2, abcd.3, self?.e?.value)
        }
        let re = e.bind(replay: false) { [weak self] e in
            self?.value = (self?.abcd?.value?.0, self?.abcd?.value?.1, self?.abcd?.value?.2, self?.abcd?.value?.3, e)
        }
        setObserving({ _ = abcd }, receipt: rabcd)
        setObserving({ _ = e }, receipt: re)
        if let v = a.value {
            a.value = v
        } else if let v = b.value {
            b.value = v
        } else if let v = c.value {
            c.value = v
        } else if let v = d.value {
            d.value = v
        } else if let v = e.value {
            e.value = v
        }
    }
}

public func zip<A, B, C, D, E>(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>, _ d: Observable<D>, _ e: Observable<E>) -> Observable<(A?, B?, C?, D?, E?)> { Zip5Observable(a, b, c, d, e) }
