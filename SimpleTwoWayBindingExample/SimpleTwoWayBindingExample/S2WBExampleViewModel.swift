//
//  File.swift
//  SimpleTwoWayBindingExample
//
//  Created by Ryan Forsythe on 3/9/20.
//  Copyright © 2020 Ryan Forsythe. All rights reserved.
//

import Foundation
import SimpleTwoWayBinding

struct S2WBExampleViewModel {
    // switch items
    let turnOn: Observable<Bool> = Observable()
    let turnOnDescription: Observable<String>
    
    // text field items
    let userEnteredText: Observable<String> = Observable()
    let processedText: Observable<String>
    
    // slider items
    let sliderPosition: Observable<Float> = Observable()
    let sliderDescription: Observable<String>
    
    // Stepper items
    let stepperPosition: Observable<Double> = Observable()
    let stepperDescription: Observable<String>
    
    // Segment items
    static let segmentImageNames = ["sun.max", "cloud.sun", "cloud", "cloud.rain", "cloud.bolt.rain"]
    let selectedSegment: Observable<Int> = Observable()
    let segmentDescription: Observable<String>
    
    // Text View items
    let textViewContents: Observable<String>
    
    init() {
        turnOnDescription = turnOn
            .map { on -> String in
                if on { return "The switch is on" }
                else { return "The switch is off" }
            }
        
        processedText = userEnteredText
            .map { "\"\($0)\" has \($0.count) characters" }
        
        sliderDescription = sliderPosition
            .map { Int($0 * 10) }
            .map { Array(repeating: "🎉", count: $0).joined() }
        
        stepperDescription = stepperPosition
            .map(Int.init)
            .map { Array(repeating: "🍕", count: $0).joined() }
        
        segmentDescription = selectedSegment
            .map { ["Sunny", "Partly Cloudy", "Cloudy", "Rain", "Thunderstorms"][$0] }
            .map { "The forecast is: \($0)" }
        
        textViewContents = zip(turnOn, sliderPosition, stepperPosition)
            .map {
                """
                The switch is on: \($0.0 ?? false)
                The slider is at: \($0.1 ?? 0)
                The stepper is at: \($0.2 ?? 0)
                """
            }
    }
}
