//
//  SearchViewController.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/14/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class SearchViewController: UIViewController {

    var searchView: SearchView!
    
    private let resultsSegueIdentifier = "ShowResults"
    
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        searchView = SearchView.newAutoLayoutView()
        searchView.delegate = self
        view.addSubview(searchView)
        
        navigationItem.title = "Virtual Sitter"
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            searchView.autoPinEdgesToSuperviewEdges()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == resultsSegueIdentifier {
            let inputs = searchView.getInputs()
            let resultsViewController = segue.destinationViewController as! ResultsViewController
            resultsViewController.viewModel = ResultsViewModel(virtualSitterService: VirtualSitterService(), startTime: inputs["startTime"]!, endTime: inputs["endTime"]!, room: inputs["room"]!, kinect: inputs["kinect"]!, floor: inputs["floor"]!, building: inputs["building"]!)
        }
    }
}

// MARK: - Search View Delegate

extension SearchViewController: SearchViewDelegate {
    func searchButtonWasClicked(searchView: SearchView, sender: UIButton!) {
        if inputsValid() {
            performSegueWithIdentifier(resultsSegueIdentifier, sender: sender)
        } else {
            let alert = UIAlertController(title: nil, message: "Enter a value for all inputs", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in }))
            presentViewController(alert, animated: true, completion: { _ in })
        }
    }
    
    func inputsValid() -> Bool {
        for (_, value) in searchView.getInputs() {
            if value.isEmpty { return false }
        }
        return true
    }
}

