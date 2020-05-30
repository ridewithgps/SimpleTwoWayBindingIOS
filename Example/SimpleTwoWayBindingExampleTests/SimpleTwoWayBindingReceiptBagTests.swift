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
        let bag = ReceiptBag()
        let o: Observable<Int> = Observable(1)
        let p: Observable<Bool> = Observable(false)
        
        var oBindingFired = false
        var pBindingFired = false
        
        o
            .pausableBind(replay: false) { _ in oBindingFired = true }
            .add(to: bag)
        p
            .pausableBind(replay: false) { _ in
                pBindingFired = true
                
        }
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
        
        o.value = 4
        p.value = true
        XCTAssert(oBindingFired)
        XCTAssert(pBindingFired)

    }
}
