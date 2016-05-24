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
    
    private static let longDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    private static let shortDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    private static let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    init(virtualSitterService: VirtualSitterService, startTime: String, endTime: String, room: String, kinect: String, floor: String, building: String) {
        func getDateString(date: String) -> String {
            guard let inputDate = ResultsViewModel.longDateFormatter.dateFromString(date) else { return date }
            return ResultsViewModel.shortDateFormatter.stringFromDate(inputDate)
        }
        
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
                return ResultsViewModel.calendar.dateByAddingUnit(.Day, value: 7, toDate: currentStartDate, options: NSCalendarOptions(rawValue: 0))!
            case 2:
                return ResultsViewModel.calendar.dateByAddingUnit(.Month, value: 1, toDate: currentStartDate, options: NSCalendarOptions(rawValue: 0))!
            case 3:
                return ResultsViewModel.calendar.dateByAddingUnit(.Year, value: 1, toDate: currentStartDate, options: NSCalendarOptions(rawValue: 0))!
            default:
                return queryEndDate
            }
        }
        
        let startDate = ResultsViewModel.longDateFormatter.dateFromString(startTime)!
        let endDate = ResultsViewModel.longDateFormatter.dateFromString(endTime)!
        let days = EventParser.datesBetween(startDate, endTime: endDate)
        
        self.virtualSitterService = virtualSitterService
        queryText = ConstantProperty("Start: \(startTime), End: \(endTime), Room: \(room), Floor: \(floor), Kinect: \(kinect), Building: \(building)")
        displayStartDate = ConstantProperty(getDateString(startTime))
        displayEndDate = ConstantProperty(getDateString(endTime))
        
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
            .map { events in
                let startDate = ResultsViewModel.longDateFormatter.dateFromString(startTime)!
                let endDate = ResultsViewModel.longDateFormatter.dateFromString(endTime)!
                return EventParser.parse(events, startTime: startDate, endTime: endDate)
            }
            .flatMapError { _ in return SignalProducer<EventData?, NoError>.empty }
        
        lineChartData <~ combineLatest(startTimeSliderValue.producer, timeScaleIndex.producer, eventData.producer)
            .observeOn(QueueScheduler())
            .map { sliderValue, scaleIndex, eventData in
                if eventData == nil { return nil }
                
                let queryStartDate = ResultsViewModel.longDateFormatter.dateFromString(startTime)!
                let queryEndDate = ResultsViewModel.longDateFormatter.dateFromString(endTime)!
                
                let startDate = getStartDate(sliderValue, days: days, queryStartDate: queryStartDate)
                let endDate = getEndDate(scaleIndex, currentStartDate: startDate, queryEndDate: queryEndDate)

                return EventParser.getLineChartData(eventData!, startTime: startDate, endTime: endDate)
            }
    }
}
