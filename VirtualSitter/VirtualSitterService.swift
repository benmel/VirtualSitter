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
import SwiftyJSON

class VirtualSitterService {
    private let provider = ReactiveCocoaMoyaProvider<VirtualSitter>()
    private let events = "eat,fall,none,sit,sleep,watch"
    
    func signalForVideoSearch(startTime: String, endTime: String, room: String, kinect: String) -> SignalProducer<[Video], Error> {
        return provider.request(.Videos(startTime: startTime, endTime: endTime, room: room, kinect: kinect))
            .observeOn(QueueScheduler())
            .filterSuccessfulStatusCodes()
            .map {
                guard let jsonArray = JSON(data: $0.data).array else { return [Video]() }
                return jsonArray.map { Video(json: $0) }
            }
    }
    
    func signalForEventSearch(startTime: String, endTime: String, room: String, kinect: String) -> SignalProducer<[KinectEvent], Error> {
        return provider.request(.Events(startTime: startTime, endTime: endTime, room: room, kinect: kinect, event: events))
            .observeOn(QueueScheduler())
            .filterSuccessfulStatusCodes()
            .map {
                guard let jsonArray = JSON(data: $0.data).array else { return [KinectEvent]() }
                return jsonArray.map { KinectEvent(json: $0) }
            }
    }
}