//
//  Video.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/19/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation

struct Video {
    let startTime: String
    let endTime: String
    let room: String
    let kinect: String
    let filePath: String
    
    init(json: NSDictionary) {
        startTime = json["Start"] as! String
        endTime = json["end"] as! String
        room = json["RoomID"] as! String
        kinect = json["KinectID"] as! String
        filePath = json["FilePath"] as! String
    }
}
