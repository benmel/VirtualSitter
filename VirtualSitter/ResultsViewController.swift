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
        
        resultsView = ResultsView(playerView: playerViewController.view, tableViewDataSource: self, tableViewDelegate: self, cellIdentifier: cellIdentifier)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultsView)
        
        playerViewController.didMoveToParentViewController(self)
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
