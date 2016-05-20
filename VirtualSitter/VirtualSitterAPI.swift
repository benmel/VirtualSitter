//
//  VirtualSitterAPI.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/19/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation
import Moya

public enum VirtualSitter {
    case Videos(startTime: String, endTime: String, room: String, kinect: String)
    case Events(startTime: String, endTime: String, room: String, kinect: String, event: String)
}

// MARK: - TargetType Protocol Implementation

extension VirtualSitter: TargetType {
    public var baseURL: NSURL { return NSURL(string: "http://129.105.36.182")! }
    
    public var path: String {
        switch self {
        case .Videos(_, _, _, _):
            return "/firstqueryVideo.php"
        case .Events(_, _, _, _, _):
            return "/mobile/event_query.php"
        }
    }
    
    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Videos(let startTime, let endTime, let room, let kinect):
            return ["from": startTime.URLEscapedString, "to": endTime.URLEscapedString, "room": room.URLEscapedString, "kinect": kinect.URLEscapedString]
        case .Events(let startTime, let endTime, let room, let kinect, let event):
            return ["start": startTime.URLEscapedString, "end": endTime.URLEscapedString, "room": room.URLEscapedString, "kinectId": kinect.URLEscapedString, "event": event.URLEscapedString]
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Videos(_, _, let room, let kinect):
            return "[{\"Start\": \"2015-03-13 13:15:04\", \"end\": \"2015-03-13 13:30:02\", \"RoomID\": \(room), \"KinectID\": \(kinect), \"FilePath\": \"Depth_20150312_130304_604.mp4\"}]".UTF8EncodedData
        case .Events(_, _, _, _, let event):
            return "[{\"startTime\": \"2015-03-12 11:16:51\", \"endTime\": \"2015-03-12 11:16:51\", \"event\": \(event)}]".UTF8EncodedData
        }
    }
}

// MARK: - Helpers

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
