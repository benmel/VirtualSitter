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
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    private var loginDisplayed = false
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loginDisplayed {
            let loginViewController = LoginViewController()
            presentViewController(loginViewController, animated: animated, completion: nil)
            loginDisplayed = true
        }
    }

    func setupView() {
        searchView = SearchView.newAutoLayoutView()
        searchView.delegate = self
        view.addSubview(searchView)
        
        navigationItem.title = "Virtual Sitter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(showLogin))
    }
    
    func showLogin(sender: UIBarButtonItem) {
        let loginViewController = LoginViewController()
        presentViewController(loginViewController, animated: true) { [weak self] in
            self?.searchView.clearInputs()
        }
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            searchView.autoPinEdgesToSuperviewEdges()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == resultsSegueIdentifier {
            let inputs = searchView.getInputs()
            let resultsViewController = segue.destinationViewController as! ResultsViewController
            let startTime = dateFormatter.dateFromString(inputs["startTime"]!)!
            let endTime = dateFormatter.dateFromString(inputs["endTime"]!)!
            
            resultsViewController.viewModel = ResultsViewModel(virtualSitterService: VirtualSitterService(), startTime: startTime, endTime: endTime, room: inputs["room"]!, kinect: inputs["kinect"]!, floor: inputs["floor"]!, building: inputs["building"]!)
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

