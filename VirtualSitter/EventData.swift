//
//  EventData.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/21/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation

struct EventData {
    let days: [NSDate]
    let eat: [Int]
    let fall: [Int]
    let none: [Int]
    let sit: [Int]
    let sleep: [Int]
    let watch: [Int]
    
    init(days: [NSDate], eat: [Int], fall: [Int], none: [Int], sit: [Int], sleep: [Int], watch: [Int]) {
        self.days = days
        self.eat = eat
        self.fall = fall
        self.none = none
        self.sit = sit
        self.sleep = sleep
        self.watch = watch
    }
}