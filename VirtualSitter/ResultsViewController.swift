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
import Moya

import enum Result.NoError
typealias NoError = Result.NoError

class ResultsViewController: UIViewController {
    var viewModel: ResultsViewModel!
    
    private let cellIdentifier = "TableCell"
    private var results = [Video]()
    
    private var topView: UIView!
    private var bottomView: UIView!
    private var queryLabel: UILabel!
    private var displayControl: UISegmentedControl!
    private var displayView: UIView!
    private var playerView: UIView!
    private var activityView: LineChartView!
    private var resultsTable: UITableView!
    private var sliderView: UIView!
    private var startTimeSlider: UISlider!
    private var sliderLabel: UILabel!
    private var minSliderLabel: UILabel!
    private var maxSliderLabel: UILabel!
    
    private let sliderSpacing: CGFloat = 40
    
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    func setupViews() {
        setupTopView()
        setupBottomView()
        setupQueryLabel()
        setupDisplayControl()
        setupDisplayView()
        setupPlayerView()
        setupActivityView()
        setupResultsTable()
        setupSliderView()
        setupStartTimeSlider()
        setupSliderLabels()
    }
    
    func setupTopView() {
        topView = UIView.newAutoLayoutView()
        view.addSubview(topView)
    }
    
    func setupBottomView() {
        bottomView = UIView.newAutoLayoutView()
        view.addSubview(bottomView)
    }
    
    func setupQueryLabel() {
        queryLabel = UILabel.newAutoLayoutView()
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
    
    // TODO: - Change video player in table view delegate
    func setupPlayerView() {
        let url = NSURL(string: "http://129.105.36.182/webfile/testvideo/20150304_172923.mp4")
        let player = AVPlayer(URL: url!)
//        let player = AVPlayer()
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
        activityView.descriptionText = ""
        activityView.xAxis.labelPosition = .Bottom
        activityView.rightAxis.drawLabelsEnabled = false
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        activityView.leftAxis.valueFormatter = numberFormatter
        activityView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        displayView.addSubview(activityView)
    }
    
    func setupResultsTable() {
        resultsTable = UITableView.newAutoLayoutView()
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        bottomView.addSubview(resultsTable)
    }
    
    func setupSliderView() {
        sliderView = UIView.newAutoLayoutView()
        bottomView.addSubview(sliderView)
    }
    
    func setupStartTimeSlider() {
        startTimeSlider = UISlider.newAutoLayoutView()
        startTimeSlider.continuous = false
        sliderView.addSubview(startTimeSlider)
    }
    
    func setupSliderLabels() {
        sliderLabel = UILabel.newAutoLayoutView()
        sliderLabel.font = UIFont.systemFontOfSize(14)
        sliderLabel.text = "Select a start date"
        sliderView.addSubview(sliderLabel)
        
        minSliderLabel = UILabel.newAutoLayoutView()
        minSliderLabel.font = UIFont.systemFontOfSize(12)
        sliderView.addSubview(minSliderLabel)
        
        maxSliderLabel = UILabel.newAutoLayoutView()
        maxSliderLabel.font = UIFont.systemFontOfSize(12)
        sliderView.addSubview(maxSliderLabel)
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
            
            bottomView.autoPinEdgeToSuperviewEdge(.Bottom)
            bottomView.autoPinEdgeToSuperviewEdge(.Leading)
            bottomView.autoPinEdgeToSuperviewEdge(.Trailing)
            bottomView.autoPinEdge(.Top, toEdge: .Bottom, ofView: displayView)
            bottomView.autoMatchDimension(.Height, toDimension: .Height, ofView: displayView)
            
            resultsTable.autoPinEdgesToSuperviewEdges()
            sliderView.autoPinEdgesToSuperviewEdges()
            
            sliderLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: sliderSpacing)
            sliderLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
            
            startTimeSlider.autoPinEdge(.Top, toEdge: .Bottom, ofView: sliderLabel)
            startTimeSlider.autoPinEdgeToSuperviewEdge(.Leading, withInset: sliderSpacing)
            startTimeSlider.autoPinEdgeToSuperviewEdge(.Trailing, withInset: sliderSpacing)
            
            minSliderLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: sliderSpacing)
            minSliderLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: startTimeSlider)
            maxSliderLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: sliderSpacing)
            maxSliderLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: startTimeSlider)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - View Model
    
    func bindViewModel() {
        queryLabel.rac_text <~ viewModel.queryText
        
        viewModel.segmentIndex <~ displayControl
            .rac_signalForControlEvents(.ValueChanged)
            .toSignalProducer()
            .flatMapError { _ in SignalProducer<AnyObject?, NoError>(value: "Segment Error") }
            .map { sender in sender as! UISegmentedControl }
            .map { $0.selectedSegmentIndex }
        
        playerView.rac_hidden <~ viewModel.playerViewHidden
        resultsTable.rac_hidden <~ viewModel.playerViewHidden
        activityView.rac_hidden <~ viewModel.activityViewHidden
        sliderView.rac_hidden <~ viewModel.activityViewHidden
        
        minSliderLabel.rac_text <~ viewModel.displayStartTime
        maxSliderLabel.rac_text <~ viewModel.displayEndTime
        
        viewModel.sliderValue <~ startTimeSlider
            .rac_signalForControlEvents(.ValueChanged)
            .toSignalProducer()
            .flatMapError { _ in SignalProducer<AnyObject?, NoError>(value: "Slider Error") }
            .map { sender in sender as! UISlider }
            .map { $0.value }
        
        viewModel.videos.producer
            .observeOn(QueueScheduler.mainQueueScheduler)
            .startWithNext { [unowned self] data in
                self.results = data
                self.resultsTable.reloadData()
            }
        
        viewModel.lineChartData.producer
            .observeOn(QueueScheduler.mainQueueScheduler)
            .startWithNext { [unowned self] data in
                self.activityView.data = data
                self.activityView.notifyDataSetChanged()
            }
    }
}

extension ResultsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = results[indexPath.row].filePath
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}

extension ResultsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        selectedResult = results[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
