//
//  ResultsViewController.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/21/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout
import AVKit
import AVFoundation
import Charts
import ReactiveCocoa

class ResultsViewController: UIViewController {
    
    var startTime: String!
    var endTime: String!
    var room: String!
    var floor: String!
    var kinect: String!
    var building: String!
    
    private let cellIdentifier = "TableCell"
    private var results = [String]()
    private var selectedResult = ""
    private var events = [NSDictionary]()
    
    private var topView: UIView!
    private var queryLabel: UILabel!
    private var displayControl: UISegmentedControl!
    private var displayView: UIView!
    private var playerView: UIView!
    private var activityView: LineChartView!
    private var resultsTable: UITableView!
    
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        getVideos()
        getEvents()
        
        setupTopView()
        setupQueryLabel()
        setupDisplayControl()
        setupDisplayView()
        setupPlayerView()
        setupActivityView()
        setupControlSignals()
        setupResultsTable()
    }
    
    func setupTopView() {
        topView = UIView.newAutoLayoutView()
        view.addSubview(topView)
    }
    
    func setupQueryLabel() {
        queryLabel = UILabel.newAutoLayoutView()
        queryLabel.text = "Start: \(startTime), End: \(endTime), Room: \(room), Floor: \(floor), Kinect: \(kinect), Building: \(building)"
        queryLabel.font = UIFont.systemFontOfSize(12)
        queryLabel.numberOfLines = 2
        topView.addSubview(queryLabel)
    }
    
    func setupDisplayControl() {
        displayControl = UISegmentedControl(items: ["Video", "Activity"])
        displayControl.translatesAutoresizingMaskIntoConstraints = false
        displayControl.selectedSegmentIndex = 0
        topView.addSubview(displayControl)
    }
    
    func setupDisplayView() {
        displayView = UIView.newAutoLayoutView()
        view.addSubview(displayView)
    }
    
    func setupPlayerView() {
//        let url = NSBundle.mainBundle().URLForResource("local_video", withExtension: "m4v")
        let url = NSURL(string: "http://129.105.36.182/webfile/testvideo/20150304_172923.mp4")
        let player = AVPlayer(URL: url!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerView = playerViewController.view
        playerView.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(playerViewController)
        displayView.addSubview(playerView)
        playerViewController.didMoveToParentViewController(self)
    }
    
    func setupActivityView() {
        activityView = LineChartView()
        
        var days = [NSDate]()
        var fall = [Int]()
        
        let inputDateFormatter = NSDateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let outputDateFormatter = NSDateFormatter()
        outputDateFormatter.dateFormat = "MM-dd"
        
        let calendar = NSCalendar.currentCalendar()
        
        for event in events {
            let date = inputDateFormatter.dateFromString(event["startTime"] as! String)
            if let lastDay = days.last {
                if calendar.compareDate(date!, toDate: lastDay, toUnitGranularity: .Day) == .OrderedSame {
                    fall[fall.count-1] += 1
                } else {
                    days.append(date!)
                    fall.append(1)
                }
            } else {
                days.append(date!)
                fall.append(1)
            }
        }
        
        var yVals = [ChartDataEntry]()
        for (index, element) in fall.enumerate() {
            yVals.append(ChartDataEntry(value: Double(element), xIndex: index))
        }
        
        let xVals = days.map { day in
            outputDateFormatter.stringFromDate(day)
        }
        
        let chartDataSet = LineChartDataSet(yVals: yVals, label: "Fall")
        chartDataSet.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        chartDataSet.setCircleColor(UIColor.redColor().colorWithAlphaComponent(0.7))
        chartDataSet.lineWidth = 2.0
        chartDataSet.circleRadius = 4.0
        chartDataSet.drawValuesEnabled = false
        let chartData = LineChartData(xVals: xVals, dataSet: chartDataSet)
        activityView.data = chartData
        
        activityView.descriptionText = ""
        activityView.xAxis.labelPosition = .Bottom
        activityView.rightAxis.drawLabelsEnabled = false
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        activityView.leftAxis.valueFormatter = numberFormatter
        activityView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        displayView.addSubview(activityView)
    }
    
    func setupControlSignals() {
        playerView.hidden = false
        activityView.hidden = true
        
        displayControl
            .rac_signalForControlEvents(.ValueChanged)
            .map { sender in sender as! UISegmentedControl }
            .map { $0.selectedSegmentIndex }
            .subscribeNext { [unowned self] index in
                self.playerView.hidden = (index as! Int) != 0
                self.activityView.hidden = (index as! Int) != 1
            }
    }
    
    func setupResultsTable() {
        resultsTable = UITableView.newAutoLayoutView()
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(resultsTable)
    }
    
    func getVideos() {
        let session = NSURLSession.sharedSession()
        let url = "http://129.105.36.182/firstqueryVideo.php?"
        let parameters = "from=\(startTime)&to=\(endTime)&room=\(room)&kinect=\(kinect)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
        let request = NSURLRequest(URL: NSURL(string: url + parameters!)!)
        
        // need to update table after receiving data
        let producer = session.rac_dataWithRequest(request)
        producer
            .on(failed: {e in print("Failure")})
            .retry(5)
            .start { [unowned self] event in
                switch event {
                case let .Next(next):
                    do {
                        let JSON = try NSJSONSerialization.JSONObjectWithData(next.0, options: .MutableContainers)
                        guard let JSONArray = JSON as? [NSDictionary] else {
                            print("Not an array")
                            return
                        }
                        for r in JSONArray {
                            let file = r["FilePath"] as! String
                            self.results.append(file)
                        }
                    }
                    catch let JSONError as NSError {
                        print("\(JSONError)")
                    }
                case let .Failed(error):
                    print("Failed: \(error)")
                case .Completed:
                    print("Completed")
                case .Interrupted:
                    print("Interrupted")
                }
            }
    }
    
    func getEvents() {
        let session = NSURLSession.sharedSession()
        let url = "http://129.105.36.182/mobile/event_query.php?"
        let parameters = "start=\(startTime)&end=\(endTime)&room=\(room)&kinectId=\(kinect)&event=fall".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
        let request = NSURLRequest(URL: NSURL(string: url + parameters!)!)
        
        let producer = session.rac_dataWithRequest(request)
        producer
            .on(failed: {e in print("Failure")})
            .retry(5)
            .start { [unowned self] event in
                switch event {
                case let .Next(next):
                    do {
                        let JSON = try NSJSONSerialization.JSONObjectWithData(next.0, options: .MutableContainers)
                        guard let JSONArray = JSON as? [NSDictionary] else {
                            print("Not an array")
                            return
                        }
                        self.events = JSONArray
                    }
                    catch let JSONError as NSError {
                        print("\(JSONError)")
                    }
                case let .Failed(error):
                    print("Failed: \(error)")
                case .Completed:
                    print("Completed Events")
                case .Interrupted:
                    print("Interrupted")
                }
        }
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            topView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            topView.autoPinEdgeToSuperviewEdge(.Leading)
            topView.autoPinEdgeToSuperviewEdge(.Trailing)
            topView.autoSetDimension(.Height, toSize: 80)
            
            queryLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 5)
            queryLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            queryLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: topView, withOffset: -10)
            queryLabel.autoSetDimension(.Height, toSize: 30)
            
            displayControl.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10)
            displayControl.autoAlignAxisToSuperviewAxis(.Vertical)
            displayControl.autoSetDimension(.Width, toSize: 160)
            displayControl.autoSetDimension(.Height, toSize: 30)
            
            displayView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topView)
            displayView.autoPinEdgeToSuperviewEdge(.Leading)
            displayView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            playerView.autoPinEdgesToSuperviewEdges()
            activityView.autoPinEdgesToSuperviewEdges()
            
            resultsTable.autoPinEdgeToSuperviewEdge(.Bottom)
            resultsTable.autoPinEdgeToSuperviewEdge(.Leading)
            resultsTable.autoPinEdgeToSuperviewEdge(.Trailing)
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: displayView)
            resultsTable.autoMatchDimension(.Height, toDimension: .Height, ofView: displayView)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
}

extension ResultsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}

extension ResultsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedResult = results[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
