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
    let playerViewHidden = MutableProperty<Bool>(false)
    let activityViewHidden = MutableProperty<Bool>(true)
    let segmentIndex = MutableProperty<Int>(0)
    let videos = MutableProperty<[Video]>([Video]())
    let lineChartData = MutableProperty<LineChartData?>(nil)
    
    private let virtualSitterService: VirtualSitterService
    
    init(virtualSitterService: VirtualSitterService, startTime: String, endTime: String, room: String, kinect: String, floor: String, building: String) {
        queryText = ConstantProperty("Start: \(startTime), End: \(endTime), Room: \(room), Floor: \(floor), Kinect: \(kinect), Building: \(building)")
        playerViewHidden <~ segmentIndex.producer.map { $0 != 0 }
        activityViewHidden <~ segmentIndex.producer.map { $0 != 1 }
        
        self.virtualSitterService = virtualSitterService
        
        self.virtualSitterService
            .signalForVideoSearch(startTime, endTime: endTime, room: room, kinect: kinect)
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
                        self.lineChartData.value = self.parseEvents(events)
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
    
    private func parseEvents(events: [KinectEvent]) -> LineChartData {
        var days = [NSDate]()
        var eat = [Int]()
        var fall = [Int]()
        var none = [Int]()
        var sit = [Int]()
        var sleep = [Int]()
        var watch = [Int]()
        
        let calendar = NSCalendar.currentCalendar()
        let inputDateFormatter = NSDateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let outputDateFormatter = NSDateFormatter()
        outputDateFormatter.dateFormat = "MM-dd"
        
        func addNewDay(date: NSDate) {
            days.append(date)
            eat.append(0)
            fall.append(0)
            none.append(0)
            sit.append(0)
            sleep.append(0)
            watch.append(0)
        }
        
        func updateEventCount(event: KinectEvent) {
            switch event.event.lowercaseString {
            case "eat":
                eat[eat.count-1] += 1
            case "fall":
                fall[fall.count-1] += 1
            case "none":
                none[none.count-1] += 1
            case "sit":
                sit[sit.count-1] += 1
            case "sleep":
                sleep[sleep.count-1] += 1
            case "watch":
                watch[watch.count-1] += 1
            default:
                break
            }
        }
        
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
        
        for event in events {
            let date = inputDateFormatter.dateFromString(event.startTime)
            if let lastDay = days.last {
                if calendar.compareDate(date!, toDate: lastDay, toUnitGranularity: .Day) == .OrderedSame {
                    updateEventCount(event)
                } else {
                    addNewDay(date!)
                    updateEventCount(event)
                }
            } else {
                addNewDay(date!)
                updateEventCount(event)
            }
        }
        
        let xVals = days.map { outputDateFormatter.stringFromDate($0) }
        let eatData = getChartDataSet(eat, label: "Eat", color: .redColor())
        let fallData = getChartDataSet(fall, label: "Fall", color: .orangeColor())
        let noneData = getChartDataSet(none, label: "None", color: .yellowColor())
        let sitData = getChartDataSet(sit, label: "Sit", color: .greenColor())
        let sleepData = getChartDataSet(sleep, label: "Sleep", color: .blueColor())
        let watchData = getChartDataSet(watch, label: "Watch", color: .purpleColor())
        
        return LineChartData(xVals: xVals, dataSets: [eatData, fallData, noneData, sitData, sleepData, watchData])
    }
}
