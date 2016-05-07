//
//  ResultsView.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/22/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class ResultsView: UIView {

    // MARK: - Views
    
    private var topView: UIView!
    private var queryLabel: UILabel!
    private var displayControl: UISegmentedControl!
    private var resultsTable: UITableView!
    private var displayView: UIView!
    private var videoView: UIView!
    private var activityView: UIView!
    
    private var didSetupConstraints = false
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    convenience init(tableViewDataSource: UITableViewDataSource, tableViewDelegate: UITableViewDelegate, cellIdentifier: String) {
        self.init(frame: CGRectZero)
        setupTable(tableViewDataSource, tableViewDelegate: tableViewDelegate, cellIdentifier: cellIdentifier)
    }
    
    func initialize() {
        setupViews()
    }
    
    func setupViews() {
        topView = UIView.newAutoLayoutView()
        addSubview(topView)
        
        queryLabel = UILabel.newAutoLayoutView()
        queryLabel.text = "Start: 1:00, End: 2:00, Room: 1, Floor: 1, Kinect: 1, Building: Smith"
        queryLabel.font = UIFont.systemFontOfSize(12)
        queryLabel.numberOfLines = 2
        topView.addSubview(queryLabel)
        
        displayControl = UISegmentedControl(items: ["Video", "Activity"])
        displayControl.translatesAutoresizingMaskIntoConstraints = false
        displayControl.selectedSegmentIndex = 0
        displayControl.addTarget(self, action: #selector(displayChanged), forControlEvents: .ValueChanged)
        topView.addSubview(displayControl)
        
        displayView = UIView.newAutoLayoutView()
        addSubview(displayView)
        
        videoView = UIView.newAutoLayoutView()
        videoView.backgroundColor = .darkGrayColor()
        displayView.addSubview(videoView)
        
        activityView = UIView.newAutoLayoutView()
        activityView.backgroundColor = .purpleColor()
        activityView.hidden = true
        displayView.addSubview(activityView)
        
        resultsTable = UITableView.newAutoLayoutView()
        addSubview(resultsTable)
    }
    
    func setupTable(tableViewDataSource: UITableViewDataSource, tableViewDelegate: UITableViewDelegate, cellIdentifier: String) {
        resultsTable.dataSource = tableViewDataSource
        resultsTable.delegate = tableViewDelegate
        resultsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            topView.autoPinEdgeToSuperviewEdge(.Top)
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
            
            videoView.autoPinEdgesToSuperviewEdges()
            activityView.autoPinEdgesToSuperviewEdges()
            
            resultsTable.autoPinEdgeToSuperviewEdge(.Bottom)
            resultsTable.autoPinEdgeToSuperviewEdge(.Leading)
            resultsTable.autoPinEdgeToSuperviewEdge(.Trailing)
            
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: displayView)
            resultsTable.autoMatchDimension(.Height, toDimension: .Height, ofView: displayView)
            
            didSetupConstraints = true
        }

        super.updateConstraints()
    }
    
    // MARK: - User Interaction
    
    func displayChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            videoView.hidden = false
            activityView.hidden = true
        } else {
            videoView.hidden = true
            activityView.hidden = false
        }
    }
    
    
}
