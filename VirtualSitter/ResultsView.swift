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
    
    private var resultsTable: UITableView!
    private var videoView: UIView!
    
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
        videoView = UIView.newAutoLayoutView()
        videoView.backgroundColor = .darkGrayColor()
        addSubview(videoView)
        
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
            videoView.autoPinEdgeToSuperviewEdge(.Top)
            videoView.autoPinEdgeToSuperviewEdge(.Leading)
            videoView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            resultsTable.autoPinEdgeToSuperviewEdge(.Bottom)
            resultsTable.autoPinEdgeToSuperviewEdge(.Leading)
            resultsTable.autoPinEdgeToSuperviewEdge(.Trailing)
            
            resultsTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoView)
            resultsTable.autoMatchDimension(.Height, toDimension: .Height, ofView: videoView)
            
            didSetupConstraints = true
        }

        super.updateConstraints()
    }
}
