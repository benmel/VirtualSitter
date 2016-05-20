//
//  KinectEvent.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/20/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation

struct KinectEvent {
    let startTime: String
    let endTime: String
    let event: String
    
    init(json: NSDictionary) {
        startTime = json["startTime"] as! String
        endTime = json["endTime"] as! String
        event = json["event"] as! String
    }
}