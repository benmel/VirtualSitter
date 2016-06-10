//
//  EventParser.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/22/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation
import Charts

class EventParser {
    private static let longDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    private static let shortDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter
    }()
    private static let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    static func parse(events: [KinectEvent], startTime: NSDate, endTime: NSDate) -> EventData {
        var days = datesBetween(startTime, endTime: endTime)
        
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
            let date = calendar.dateFromComponents(components)!
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
        
        let eatSum = eat.reduce(0, combine: +)
        let fallSum = fall.reduce(0, combine: +)
        let noneSum = none.reduce(0, combine: +)
        let sitSum = sit.reduce(0, combine: +)
        let sleepSum = sleep.reduce(0, combine: +)
        let watchSum = watch.reduce(0, combine: +)
        
        return EventData(days: days, eat: eat, fall: fall, none: none, sit: sit, sleep: sleep, watch: watch, eatSum: eatSum, fallSum: fallSum, noneSum: noneSum, sitSum: sitSum, sleepSum: sleepSum, watchSum: watchSum)
    }
    
    static func getLineChartData(eventData: EventData, startTime: NSDate, endTime: NSDate) -> LineChartData {
        var days = [NSDate]()
        var eat = [Int]()
        var fall = [Int]()
        var none = [Int]()
        var sit = [Int]()
        var sleep = [Int]()
        var watch = [Int]()
        
        func getChartDataSet(eventCounts: [Int], sum: Int, label: String, color: UIColor) -> ChartDataSet {
            if sum == 0 { return LineChartDataSet() }
            
            var yVals = [ChartDataEntry]()
            for (index, element) in eventCounts.enumerate() {
                yVals.append(ChartDataEntry(value: Double(element), xIndex: index))
            }
            let chartDataSet = LineChartDataSet(yVals: yVals, label: label)
            chartDataSet.setColor(color.colorWithAlphaComponent(0.5))
            chartDataSet.setCircleColor(color.colorWithAlphaComponent(0.7))
            chartDataSet.lineWidth = 2.0
            chartDataSet.circleRadius = 3.0
            chartDataSet.drawValuesEnabled = false
            chartDataSet.drawCircleHoleEnabled = false
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
        
        let xVals = days.map { shortDateFormatter.stringFromDate($0) }
        let eatData = getChartDataSet(eat, sum: eventData.eatSum, label: "Eat", color: .redColor())
        let fallData = getChartDataSet(fall, sum: eventData.fallSum, label: "Fall", color: .orangeColor())
        let noneData = getChartDataSet(none, sum: eventData.noneSum, label: "None", color: .yellowColor())
        let sitData = getChartDataSet(sit, sum: eventData.sitSum, label: "Sit", color: .greenColor())
        let sleepData = getChartDataSet(sleep, sum: eventData.sleepSum, label: "Sleep", color: .blueColor())
        let watchData = getChartDataSet(watch, sum: eventData.watchSum, label: "Watch", color: .purpleColor())
        
        return LineChartData(xVals: xVals, dataSets: [eatData, fallData, noneData, sitData, sleepData, watchData])
    }
    
    static func datesBetween(startTime: NSDate, endTime: NSDate) -> [NSDate] {
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