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
    let queryText: ConstantProperty<String>
    let displayStartTime: ConstantProperty<String>
    let displayEndTime: ConstantProperty<String>
    let sliderStartTime: MutableProperty<String>
    let sliderEndTime: MutableProperty<String>
    
    let playerViewHidden = MutableProperty<Bool>(false)
    let activityViewHidden = MutableProperty<Bool>(true)
    let segmentIndex = MutableProperty<Int>(0)
    let sliderValue = MutableProperty<Float>(0)
    
    let videos = MutableProperty<[Video]>([Video]())
    private let eventData = MutableProperty<EventData?>(nil)
    let lineChartData = MutableProperty<LineChartData?>(nil)
    
    private let days: [NSDate]
    private let selectedStartDate: MutableProperty<String>
    
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
    
    
    private let virtualSitterService: VirtualSitterService
    
    init(virtualSitterService: VirtualSitterService, startTime: String, endTime: String, room: String, kinect: String, floor: String, building: String) {
        self.virtualSitterService = virtualSitterService
        
        queryText = ConstantProperty("Start: \(startTime), End: \(endTime), Room: \(room), Floor: \(floor), Kinect: \(kinect), Building: \(building)")
        
        displayStartTime = ConstantProperty(ResultsViewModel.getDateString(startTime))
        displayEndTime = ConstantProperty(ResultsViewModel.getDateString(endTime))
        
        sliderStartTime = MutableProperty(displayStartTime.value)
        sliderEndTime = MutableProperty(displayEndTime.value)
        
        playerViewHidden <~ segmentIndex.producer.map { $0 != 0 }
        activityViewHidden <~ segmentIndex.producer.map { $0 != 1 }
        
        let startDate = ResultsViewModel.longDateFormatter.dateFromString(startTime)!
        let endDate = ResultsViewModel.longDateFormatter.dateFromString(endTime)!
        days = ResultsViewModel.datesBetween(startDate, endTime: endDate)
        selectedStartDate = MutableProperty(startTime)
        
        selectedStartDate <~ sliderValue.producer
            .map { [unowned self] value in
                if self.days.count == 0 {
                    return startTime
                } else {
                    let index = Int(value * Float(self.days.count-1))
                    let date = self.days[index]
                    return ResultsViewModel.longDateFormatter.stringFromDate(date)
                }
            }
        
        selectedStartDate.producer
            .observeOn(QueueScheduler())
            .startWithNext { [unowned self] value in
                let startDate = ResultsViewModel.longDateFormatter.dateFromString(value)!
                let endDate = ResultsViewModel.longDateFormatter.dateFromString(endTime)!
                if let eventData = self.eventData.value {
                    self.lineChartData.value = ResultsViewModel.getLineChartData(eventData, startTime: startDate, endTime: endDate)
                }
            }
        
        lineChartData <~ eventData.producer
            .map { [unowned self] value in
                guard let eventData = value else {
                    return nil
                }
                let startDate = ResultsViewModel.longDateFormatter.dateFromString(self.selectedStartDate.value)!
                let endDate = ResultsViewModel.shortDateFormatter.dateFromString(self.displayEndTime.value)!
                return ResultsViewModel.getLineChartData(eventData, startTime: startDate, endTime: endDate)
            }

        self.virtualSitterService
            .signalForVideoSearch(startTime, endTime: endTime, room: room, kinect: kinect)
            .observeOn(QueueScheduler())
            .retry(5)
            .filterSuccessfulStatusCodes()
            .start { [unowned self] event -> Void in
                switch event {
                case .Next(let data):
                    do {
                        let JSON = try data.mapJSON()
                        guard let JSONArray = JSON as? [NSDictionary] else {
                            return
                        }
                        self.videos.value = JSONArray.map { Video(json: $0) }
                    }
                    catch let JSONError as NSError {
                        print(JSONError)
                    }
                case .Failed(let error):
                    print(error)
                default:
                    break
                }
            }
        
        self.virtualSitterService
            .signalForEventSearch(startTime, endTime: endTime, room: room, kinect: kinect)
            .observeOn(QueueScheduler())
            .retry(5)
            .filterSuccessfulStatusCodes()
            .start { [unowned self] event -> Void in
                switch event {
                case .Next(let data):
                    do {
                        let JSON = try data.mapJSON()
                        guard let JSONArray = JSON as? [NSDictionary] else {
                            return
                        }
                        let events = JSONArray.map { KinectEvent(json: $0) }
                        let startDate = ResultsViewModel.longDateFormatter.dateFromString(startTime)!
                        let endDate = ResultsViewModel.longDateFormatter.dateFromString(endTime)!
                        self.eventData.value = ResultsViewModel.parseEvents(events, startTime: startDate, endTime: endDate)
                    }
                    catch let JSONError as NSError {
                        print(JSONError)
                    }
                case .Failed(let error):
                    print(error)
                default:
                    break
                }
            }
    }
    
    private class func getDateString(date: String) -> String {
        guard let inputDate = longDateFormatter.dateFromString(date) else {
            return date
        }
        return shortDateFormatter.stringFromDate(inputDate)
    }

    private class func parseEvents(events: [KinectEvent], startTime: NSDate, endTime: NSDate) -> EventData {
        var days = ResultsViewModel.datesBetween(startTime, endTime: endTime)

        var eat = [Int](count: days.count, repeatedValue: 0)
        var fall = [Int](count: days.count, repeatedValue: 0)
        var none = [Int](count: days.count, repeatedValue: 0)
        var sit = [Int](count: days.count, repeatedValue: 0)
        var sleep = [Int](count: days.count, repeatedValue: 0)
        var watch = [Int](count: days.count, repeatedValue: 0)
        
        func updateEventCount(index: Int, event: KinectEvent) {
            switch event.event.lowercaseString {
            case "eat":
                eat[index] += 1
            case "fall":
                fall[index] += 1
            case "none":
                none[index] += 1
            case "sit":
                sit[index] += 1
            case "sleep":
                sleep[index] += 1
            case "watch":
                watch[index] += 1
            default:
                break
            }
        }
        
        var eventsDict = [NSDate: [KinectEvent]]()
        for event in events {
            let longDate = longDateFormatter.dateFromString(event.startTime)
            let components = calendar.components([.Month, .Day, .Year], fromDate: longDate!)
            let date = (calendar.dateFromComponents(components))!
            var values = eventsDict[date]
            if values != nil {
                values!.append(event)
                eventsDict[date] = values
            } else {
                eventsDict[date] = [event]
            }
        }
        
        for (index, element) in days.enumerate() {
            let values = eventsDict[element]
            if values != nil {
                for value in values! {
                    updateEventCount(index, event: value)
                }
            }
        }

        return EventData(days: days, eat: eat, fall: fall, none: none, sit: sit, sleep: sleep, watch: watch)
    }
    
    private class func getLineChartData(eventData: EventData, startTime: NSDate, endTime: NSDate) -> LineChartData {
        var days = [NSDate]()
        var eat = [Int]()
        var fall = [Int]()
        var none = [Int]()
        var sit = [Int]()
        var sleep = [Int]()
        var watch = [Int]()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        func getChartDataSet(eventCounts: [Int], label: String, color: UIColor) -> ChartDataSet {
            var yVals = [ChartDataEntry]()
            for (index, element) in eventCounts.enumerate() {
                yVals.append(ChartDataEntry(value: Double(element), xIndex: index))
            }
            let chartDataSet = LineChartDataSet(yVals: yVals, label: label)
            chartDataSet.setColor(color.colorWithAlphaComponent(0.5))
            chartDataSet.setCircleColor(color.colorWithAlphaComponent(0.7))
            chartDataSet.lineWidth = 2.0
            chartDataSet.circleRadius = 4.0
            chartDataSet.drawValuesEnabled = false
            return chartDataSet
        }
        
        for (index, day) in eventData.days.enumerate() {
            if (calendar.compareDate(day, toDate: startTime, toUnitGranularity: .Day) != .OrderedAscending) && (calendar.compareDate(day, toDate: endTime, toUnitGranularity: .Day) != .OrderedDescending) {
                days.append(day)
                eat.append(eventData.eat[index])
                fall.append(eventData.fall[index])
                none.append(eventData.none[index])
                sit.append(eventData.sit[index])
                sleep.append(eventData.sleep[index])
                watch.append(eventData.watch[index])
            }
        }
        
        let xVals = days.map { dateFormatter.stringFromDate($0) }
        let eatData = getChartDataSet(eat, label: "Eat", color: .redColor())
        let fallData = getChartDataSet(fall, label: "Fall", color: .orangeColor())
        let noneData = getChartDataSet(none, label: "None", color: .yellowColor())
        let sitData = getChartDataSet(sit, label: "Sit", color: .greenColor())
        let sleepData = getChartDataSet(sleep, label: "Sleep", color: .blueColor())
        let watchData = getChartDataSet(watch, label: "Watch", color: .purpleColor())
        
        return LineChartData(xVals: xVals, dataSets: [eatData, fallData, noneData, sitData, sleepData, watchData])
    }
    
    private class func datesBetween(startTime: NSDate, endTime: NSDate) -> [NSDate] {
        let startComponents = calendar.components([.Month, .Day, .Year], fromDate: startTime)
        let startDate = calendar.dateFromComponents(startComponents)!
        let endComponents = calendar.components([.Month, .Day, .Year], fromDate: endTime)
        let endDate = calendar.dateFromComponents(endComponents)!
        
        var dates = [NSDate]()
        var currentDate = startDate
        while calendar.compareDate(currentDate, toDate: endDate, toUnitGranularity: .Day) != .OrderedDescending {
            dates.append(currentDate)
            currentDate = (calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions(rawValue: 0)))!
        }
        return dates
    }
}
