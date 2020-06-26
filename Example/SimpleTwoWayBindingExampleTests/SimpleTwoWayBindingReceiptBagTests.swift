//
//  SimpleTwoWayBindingReceiptBagTests.swift
//  SimpleTwoWayBindingExampleTests
//
//  Created by Ryan Forsythe on 5/29/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

@testable import SimpleTwoWayBinding
import XCTest

class SimpleTwoWayBindingReceiptBagTests: XCTestCase {
    func testPauseUnpause() {
        let bag = ReceiptBag(handleBackgroundNotifications: false)
        let o: Observable<Int> = Observable(1)
        let p: Observable<Bool> = Observable(false)
        
        var oBindingFired = false
        var pBindingFired = false
        
        o
            .pausableBind(replay: false) { _ in oBindingFired = true }
            .add(to: bag)
        p
            .pausableBind(replay: false) { _ in pBindingFired = true }
            .add(to: bag)
        
        o.value = 2
        XCTAssert(oBindingFired)
        XCTAssertFalse(pBindingFired)
        p.value = true
        XCTAssert(pBindingFired)
        
        oBindingFired = false
        pBindingFired = false
        
        bag.pause()
        
        o.value = 3
        p.value = false
        XCTAssertFalse(oBindingFired)
        XCTAssertFalse(pBindingFired)

        bag.unpause()
        
        // Bags always replay the last values into the bindings after an unpause
        XCTAssert(oBindingFired)
        XCTAssert(pBindingFired)

        oBindingFired = false
        pBindingFired = false
        
        o.value = 4
        p.value = true
        XCTAssert(oBindingFired)
        XCTAssert(pBindingFired)

    }
    
    func testPauseOnBackground() {
        let bag = ReceiptBag()
        let o: Observable<Int> = Observable(1)
        
        var oBindingFired = false
        
        o
            .pausableBind(replay: false) { _ in oBindingFired = true }
            .add(to: bag)
        
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        o.value = 2
        XCTAssertFalse(oBindingFired)
        
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        
        o.value = 3
        XCTAssert(oBindingFired)
        
    }
    
    func alwaysFails_testPauseDoesntDoubleNotify() {
        let bag = ReceiptBag()
        let o: Observable<Int> = Observable(1)
        
        var binding1FireCount = 0
        var binding2FireCount = 0
        
        o
            .pausableBind(replay: false) { _ in binding1FireCount += 1 }
            .add(to: bag)
        o
            .pausableBind(replay: false) { _ in binding2FireCount += 1 }
            .add(to: bag)
        
        bag.pause()
        o.value = 42
        bag.unpause()
        XCTAssertEqual(binding1FireCount, 1)
        XCTAssertEqual(binding2FireCount, 1)
    }
}
