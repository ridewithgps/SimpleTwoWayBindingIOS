//
//  SimpleTwoWayBindingExampleUITests.swift
//  SimpleTwoWayBindingExampleUITests
//
//  Created by Ryan Forsythe on 3/6/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import XCTest

class SimpleTwoWayBindingExampleUITests: XCTestCase {

    override func setUp() {
        XCUIApplication().launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIApplication().terminate()
    }

    func testSwitch() {
        let app = XCUIApplication()
        let cellSwitch = app.switches["switch"]
        let cellInfo = app.staticTexts["switchLabel"]
        
        let startText = cellInfo.label
        cellSwitch.swipeLeft() // No-op
        XCTAssertEqual(cellSwitch.label, startText)
        
        cellSwitch.swipeRight() // Turn it on
        XCTAssertEqual(cellSwitch.label, "The switch is on")
    }
    
    func testTextField() {
        let app = XCUIApplication()
        let textField = app.textFields["textField"]
        let textInfo = app.staticTexts["textFieldInformation"]
        
        guard let originalValue = textField.value as? String else { return XCTFail() }
        textField.tap()
        textField.typeText("1234")
        var expectedCount = originalValue.count + 4
        var expectedTFValue = originalValue + "1234"
        let expectedInfo = "\"\(expectedTFValue)\" has \(expectedCount) characters"
        XCTAssertEqual(textInfo.label, expectedInfo)
        
        textField.typeText("5")
        expectedCount += 1
        expectedTFValue += "5"
        let expectedInfo2 = "\"\(expectedTFValue)\" has \(expectedCount) characters"
        XCTAssertEqual(textInfo.label, expectedInfo2)
    }
    
    func testSlider() {
        let app = XCUIApplication()
        let slider = app.sliders["slider"]
        let sliderInfo = app.staticTexts["sliderInformation"]
        
        slider.adjust(toNormalizedSliderPosition: 0.51)
        XCTAssertEqual(sliderInfo.label, "🎉🎉🎉🎉🎉")
        
        slider.adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(sliderInfo.label, "")
    }
    
    func testStepper() {
        let app = XCUIApplication()
        let stepper = app.steppers["stepper"]
        let stepperInfo = app.staticTexts["stepperInformation"]
        
        // Irritating. Steppers render out to two buttons and don't retain any evidence of their original accessibilityIdentifier.
        let incButton = app.buttons["Increment"]
        let decButton = app.buttons["Decrement"]
        incButton.tap()
        XCTAssertEqual(stepperInfo.label, "🍕")
        incButton.tap()
        XCTAssertEqual(stepperInfo.label, "🍕🍕")
        decButton.tap()
        decButton.tap()
        XCTAssertEqual(stepperInfo.label, "")
    }
    
    func testSegmentedControl() {
        let app = XCUIApplication()
        let segmentedControl = app.segmentedControls["segmentedControl"]
        let segmentInfo = app.staticTexts["segmentedControlInformation"]
        
        let sunnyButton = segmentedControl.buttons["sun.max"]
        let tstormButton = segmentedControl.buttons["cloud.bolt.rain"]
        
        tstormButton.tap()
        XCTAssertEqual(segmentInfo.label, "The forecast is: Thunderstorms")
        sunnyButton.tap()
        XCTAssertEqual(segmentInfo.label, "The forecast is: Sunny")
    }
    
    func testTextView() {
        let app = XCUIApplication()
        let cellSwitch = app.switches["switch"]
        let slider = app.sliders["slider"]
        let stepper = app.steppers["stepper"]
        let textView = app.textViews["textView"]
        
        cellSwitch.swipeRight()
        guard let switchChangedTVValue = textView.value as? String else { return XCTFail() }
        let tvLine = switchChangedTVValue.split(separator: "\n")
            .filter { $0.starts(with: "The switch is on:") }
        XCTAssertEqual(tvLine.first, "The switch is on: true")
    }
}
