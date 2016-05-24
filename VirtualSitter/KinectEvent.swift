//
//  KinectEvent.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/20/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import SwiftyJSON

struct KinectEvent {
    let startTime: String
    let endTime: String
    let event: String
    
    init(json: JSON) {
        startTime = json["startTime"].stringValue
        endTime = json["endTime"].stringValue
        event = json["event"].stringValue
    }
}