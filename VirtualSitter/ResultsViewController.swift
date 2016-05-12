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

class ResultsViewController: UIViewController {
    
    private let cellIdentifier = "TableCell"
    private let results = ["Result 1", "Result 2", "Result 3", "Result 4", "Result 5", "Result 6"]
    private let resultSegueIdentifier = "ShowResult"
    private var selectedResult = ""
    
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
        setupTopView()
        setupQueryLabel()
        setupDisplayControl()
        setupDisplayView()
        setupPlayerView()
        setupActivityView()
        setupResultsTable()
    }
    
    func setupTopView() {
        topView = UIView.newAutoLayoutView()
        view.addSubview(topView)
    }
    
    func setupQueryLabel() {
        queryLabel = UILabel.newAutoLayoutView()
        queryLabel.text = "Start: 1:00, End: 2:00, Room: 1, Floor: 1, Kinect: 1, Building: Smith"
        queryLabel.font = UIFont.systemFontOfSize(12)
        queryLabel.numberOfLines = 2
        topView.addSubview(queryLabel)
    }
    
    func setupDisplayControl() {
        displayControl = UISegmentedControl(items: ["Video", "Activity"])
        displayControl.translatesAutoresizingMaskIntoConstraints = false
        displayControl.selectedSegmentIndex = 0
        //        reactive for target
        //        displayControl.addTarget(self, action: #selector(displayChanged), forControlEvents: .ValueChanged)
        topView.addSubview(displayControl)
    }
    
    func setupDisplayView() {
        displayView = UIView.newAutoLayoutView()
        view.addSubview(displayView)
    }
    
    func setupPlayerView() {
        let url = NSBundle.mainBundle().URLForResource("local_video", withExtension: "m4v")
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
        
        let days = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]
        let walking = [2, 3, 4, 1, 0, 5, 6]
        
        var yVals = [ChartDataEntry]()
        for (index, element) in walking.enumerate() {
            yVals.append(ChartDataEntry(value: Double(element), xIndex: index))
        }
        
        let chartDataSet = LineChartDataSet(yVals: yVals, label: "Walking")
        chartDataSet.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        chartDataSet.setCircleColor(UIColor.redColor().colorWithAlphaComponent(0.7))
        chartDataSet.lineWidth = 2.0
        chartDataSet.circleRadius = 4.0
        chartDataSet.drawValuesEnabled = false
        let chartData = LineChartData(xVals: days, dataSet: chartDataSet)
        activityView.data = chartData
        
        activityView.descriptionText = ""
        activityView.xAxis.labelPosition = .Bottom
        activityView.rightAxis.drawLabelsEnabled = false
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        activityView.leftAxis.valueFormatter = numberFormatter
        activityView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

        activityView.hidden = true
        displayView.addSubview(activityView)
    }
    
    func setupResultsTable() {
        resultsTable = UITableView.newAutoLayoutView()
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(resultsTable)
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
