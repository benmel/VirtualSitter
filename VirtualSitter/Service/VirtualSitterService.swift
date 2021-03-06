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

public enum LoginStatus {
    case Succeeded
    case Failed
    case Pending
    case Unattempted
}

public enum RegistrationStatus {
    case Succeeded
    case Failed
    case Unattempted
}

class VirtualSitterService {
    private let provider = ReactiveCocoaMoyaProvider<VirtualSitter>()
    private let events = "eat,fall,none,sit,sleep,watch"
    
    func signalForVideoSearch(startTime: NSDate, endTime: NSDate, room: String, kinect: String) -> SignalProducer<[Video], Error> {
        return provider.request(.Videos(startTime: startTime, endTime: endTime, room: room, kinect: kinect))
            .observeOn(QueueScheduler())
            .filterSuccessfulStatusCodes()
            .map {
                guard let jsonArray = JSON(data: $0.data).array else { return [Video]() }
                return jsonArray.map { Video(json: $0) }
            }
    }
    
    func signalForPatientVideoSearch(patient: String, kinect: String) -> SignalProducer<[Video], Error> {
        return provider.request(.PatientVideos(patient: patient, kinect: kinect))
            .observeOn(QueueScheduler())
            .filterSuccessfulStatusCodes()
            .map {
                guard let jsonArray = JSON(data: $0.data).array else { return [Video]() }
                return jsonArray.map { Video(json: $0) }
        }
    }
    
    func signalForEventSearch(startTime: NSDate, endTime: NSDate, room: String, kinect: String) -> SignalProducer<[KinectEvent], Error> {
        return provider.request(.Events(startTime: startTime, endTime: endTime, room: room, kinect: kinect, event: events))
            .observeOn(QueueScheduler())
            .filterSuccessfulStatusCodes()
            .map {
                guard let jsonArray = JSON(data: $0.data).array else { return [KinectEvent]() }
                return jsonArray.map { KinectEvent(json: $0) }
            }
    }
    
    func signalForPatientEventSearch(patient: String, kinect: String) -> SignalProducer<[KinectEvent], Error> {
        return provider.request(.PatientEvents(patient: patient, kinect: kinect))
            .observeOn(QueueScheduler())
            .filterSuccessfulStatusCodes()
            .map {
                guard let jsonArray = JSON(data: $0.data).array else { return [KinectEvent]() }
                return jsonArray.map { KinectEvent(json: $0) }
        }
    }
    
    func signalForLogin(email: String, password: String) -> SignalProducer<LoginStatus, Error> {
        return provider.request(.Login(email: email, password: password))
            .filterSuccessfulStatusCodes()
            .map {
                guard let result = String(data: $0.data, encoding: NSUTF8StringEncoding) else { return LoginStatus.Failed }
                switch result {
                    case "acceptted":
                        return LoginStatus.Succeeded
                    case "pending":
                        return LoginStatus.Pending
                    default:
                        return LoginStatus.Failed
                }
            }
    }
    
    func signalForRegistration(email: String, password: String) -> SignalProducer<RegistrationStatus, Error> {
        return provider.request(.Register(email: email, password: password))
            .filterSuccessfulStatusCodes()
            .map {
                guard let result = String(data: $0.data, encoding: NSUTF8StringEncoding) else { return RegistrationStatus.Failed }
                return result == "success" ? RegistrationStatus.Succeeded : RegistrationStatus.Failed
        }
    }
    
}