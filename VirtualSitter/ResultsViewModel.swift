//
//  ResultsViewModel.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/18/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Charts

class ResultsViewModel {
    private let virtualSitterService: VirtualSitterService
    
    let queryText: ConstantProperty<String>
    let displayStartDate: ConstantProperty<String>
    let displayEndDate: ConstantProperty<String>
    
    let displaySegmentIndex = MutableProperty<Int>(0)
    let playerViewHidden = MutableProperty<Bool>(false)
    let activityViewHidden = MutableProperty<Bool>(true)

    let startTimeSliderValue = MutableProperty<Float>(0)
    let timeScaleIndex = MutableProperty<Int>(0)
    
    let videos = MutableProperty<[Video]>([Video]())
    private let eventData = MutableProperty<EventData?>(nil)
    let lineChartData = MutableProperty<LineChartData?>(nil)
    
    init(virtualSitterService: VirtualSitterService, startTime: NSDate, endTime: NSDate, room: String, kinect: String, floor: String, building: String) {
        
        let shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateFormat = "yyyy-MM-dd"
        let longDateFormatter = NSDateFormatter()
        longDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        func getStartDate(sliderValue: Float, days: [NSDate], queryStartDate: NSDate) -> NSDate {
            if days.count == 0 {
                return queryStartDate
            } else {
                let index = Int(sliderValue * Float(days.count-1))
                return days[index]
            }
        }
        
        func getEndDate(scaleIndex: Int, currentStartDate: NSDate, queryEndDate: NSDate) -> NSDate {
            switch scaleIndex {
            case 1:
                return calendar.dateByAddingUnit(.Day, value: 7, toDate: currentStartDate, options: NSCalendarOptions(rawValue: 0))!
            case 2:
                return calendar.dateByAddingUnit(.Month, value: 1, toDate: currentStartDate, options: NSCalendarOptions(rawValue: 0))!
            case 3:
                return calendar.dateByAddingUnit(.Year, value: 1, toDate: currentStartDate, options: NSCalendarOptions(rawValue: 0))!
            default:
                return queryEndDate
            }
        }
        
        let days = EventParser.datesBetween(startTime, endTime: endTime)
        
        self.virtualSitterService = virtualSitterService
        displayStartDate = ConstantProperty(shortDateFormatter.stringFromDate(startTime))
        displayEndDate = ConstantProperty(shortDateFormatter.stringFromDate(endTime))
        queryText = ConstantProperty("Start: \(longDateFormatter.stringFromDate(startTime)), End: \(longDateFormatter.stringFromDate(endTime)), Room: \(room), Floor: \(floor), Kinect: \(kinect), Building: \(building)")
        
        displaySegmentIndex.producer.startWithSignal { signal,_ in
            playerViewHidden <~ signal.map { $0 != 0 }
            activityViewHidden <~ signal.map { $0 != 1 }
        }
        
        videos <~ self.virtualSitterService.signalForVideoSearch(startTime, endTime: endTime, room: room, kinect: kinect)
            .observeOn(QueueScheduler())
            .retry(5)
            .flatMapError { _ in return SignalProducer<[Video], NoError>.empty }
        
        eventData <~ self.virtualSitterService.signalForEventSearch(startTime, endTime: endTime, room: room, kinect: kinect)
            .observeOn(QueueScheduler())
            .retry(5)
            .map { EventParser.parse($0, startTime: startTime, endTime: endTime) }
            .flatMapError { _ in return SignalProducer<EventData?, NoError>.empty }
        
        lineChartData <~ combineLatest(startTimeSliderValue.producer, timeScaleIndex.producer, eventData.producer)
            .observeOn(QueueScheduler())
            .map { sliderValue, scaleIndex, eventData in
                if eventData == nil { return nil }
                let startDate = getStartDate(sliderValue, days: days, queryStartDate: startTime)
                let endDate = getEndDate(scaleIndex, currentStartDate: startDate, queryEndDate: endTime)
                return EventParser.getLineChartData(eventData!, startTime: startDate, endTime: endDate)
            }
    }
    
    func textForVideosRow(row: Int) -> String {
        return videos.value[row].filePath
    }
    
    func videosCount() -> Int {
        return videos.value.count
    }
}
