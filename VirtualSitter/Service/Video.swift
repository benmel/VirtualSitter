//
//  Video.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/19/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import SwiftyJSON

struct Video {
    let startTime: String
    let endTime: String
    let room: String
    let kinect: String
    let filePath: String
    
    init(json: JSON) {
        startTime = json["Start"].stringValue
        endTime = json["end"].stringValue
        room = json["RoomID"].stringValue
        kinect = json["KinectID"].stringValue
        filePath = json["FilePath"].stringValue
    }
}
