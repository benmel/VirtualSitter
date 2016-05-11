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

    var resultsView: ResultsView!
    
    private let cellIdentifier = "TableCell"
    private let results = ["Result 1", "Result 2", "Result 3", "Result 4", "Result 5", "Result 6"]
    private let resultSegueIdentifier = "ShowResult"
    private var selectedResult = ""
    
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let url = NSBundle.mainBundle().URLForResource("local_video", withExtension: "m4v")
        let player = AVPlayer(URL: url!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(playerViewController)
        
        let chart = LineChartView()
        setupChart(chart)
        
        resultsView = ResultsView(playerView: playerViewController.view, activityView: chart, tableViewDataSource: self, tableViewDelegate: self, cellIdentifier: cellIdentifier)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultsView)
        
        playerViewController.didMoveToParentViewController(self)
    }
    
    func setupChart(chart: LineChartView) {
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
        chart.data = chartData
        
        chart.descriptionText = ""
        chart.xAxis.labelPosition = .Bottom
        chart.rightAxis.drawLabelsEnabled = false
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        chart.leftAxis.valueFormatter = numberFormatter
        chart.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            resultsView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            resultsView.autoPinEdgeToSuperviewEdge(.Bottom)
            resultsView.autoPinEdgeToSuperviewEdge(.Leading)
            resultsView.autoPinEdgeToSuperviewEdge(.Trailing)
            
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
