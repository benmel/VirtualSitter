//
//  VirtualSitterService.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/18/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Moya

class VirtualSitterService {
    private let provider = ReactiveCocoaMoyaProvider<VirtualSitter>()
    private let events = "eat,fall,none,sit,sleep,watch"
    
    func signalForVideoSearch(startTime: String, endTime: String, room: String, kinect: String) -> SignalProducer<Response, Error> {
        return provider.request(.Videos(startTime: startTime, endTime: endTime, room: room, kinect: kinect))
    }
    
    func signalForEventSearch(startTime: String, endTime: String, room: String, kinect: String) -> SignalProducer<Response, Error> {
        return provider.request(.Events(startTime: startTime, endTime: endTime, room: room, kinect: kinect, event: events))
    }
}