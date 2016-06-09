//
//  SearchViewController.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/14/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout
import ReactiveCocoa

class SearchViewController: UIViewController {

    private var viewModel: SearchViewModel!
    
    private var displayControl: UISegmentedControl!
    private var searchView: SearchView!
    
    private var patientSearchView: UIView!
    private var labelsView: UIView!
    private var inputsView: UIView!
    private var patientLabel: UILabel!
    private var kinectLabel: UILabel!
    private var patientInput: UITextField!
    private var kinectInput: UITextField!
    private var patientSearchButton: UIButton!
    
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
        viewModel = SearchViewModel()
        setupView()
        bindViewModel()
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
        view.backgroundColor = UIColor(red: 0.85, green: 0.82, blue: 0.91, alpha: 1.0)
        setupDisplayControl()
        setupTimeSearchView()
        setupPatientView()
        
        navigationItem.title = "Virtual Sitter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(showLogin))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(red: 0.6, green: 0, blue: 1, alpha: 1)
    }
    
    func showLogin(sender: UIBarButtonItem) {
        let loginViewController = LoginViewController()
        presentViewController(loginViewController, animated: true) { [weak self] in
            self?.searchView.clearInputs()
        }
    }
    
    func setupDisplayControl() {
        displayControl = UISegmentedControl(items: ["Time Search", "Patient Search"])
        displayControl.translatesAutoresizingMaskIntoConstraints = false
        displayControl.tintColor = UIColor(red: 0.6, green: 0, blue: 1, alpha: 1)
        displayControl.selectedSegmentIndex = 0
        view.addSubview(displayControl)
    }
    
    func setupTimeSearchView() {
        searchView = SearchView.newAutoLayoutView()
        searchView.delegate = self
        view.addSubview(searchView)
    }
    
    func setupPatientView() {
        patientSearchView = UIView.newAutoLayoutView()
        view.addSubview(patientSearchView)
        
        labelsView = UIView.newAutoLayoutView()
        inputsView = UIView.newAutoLayoutView()
        patientSearchView.addSubview(labelsView)
        patientSearchView.addSubview(inputsView)
        
        patientLabel = UILabel.newAutoLayoutView()
        patientLabel.text = "Patient ID"
        labelsView.addSubview(patientLabel)
        kinectLabel = UILabel.newAutoLayoutView()
        kinectLabel.text = "Kinect"
        labelsView.addSubview(kinectLabel)
        
        patientInput = UITextField.newAutoLayoutView()
        patientInput.backgroundColor = .whiteColor()
        patientInput.keyboardType = .NumberPad
        inputsView.addSubview(patientInput)
        kinectInput = UITextField.newAutoLayoutView()
        kinectInput.backgroundColor = .whiteColor()
        kinectInput.keyboardType = .NumberPad
        inputsView.addSubview(kinectInput)
        
        patientSearchButton = UIButton(type: .Custom)
        patientSearchButton.translatesAutoresizingMaskIntoConstraints = false
        patientSearchButton.setTitle("Search", forState: .Normal)
        patientSearchButton.backgroundColor = UIColor(red: 0.6, green: 0, blue: 1, alpha: 1)
        patientSearchButton.addTarget(self, action: #selector(patientSearchButtonClicked), forControlEvents: .TouchUpInside)
        patientSearchView.addSubview(patientSearchButton)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        patientSearchView.addGestureRecognizer(tapRecognizer)
    }
    
    func dismissKeyboard() {
        patientSearchView.endEditing(true)
    }
    
    func patientSearchButtonClicked(sender: UIButton) {
        if let patientText = patientInput.text, kinectText = kinectInput.text {
            if !patientText.isEmpty && !kinectText.isEmpty {
                
            } else {
                let alert = UIAlertController(title: "Error", message: "Enter a value for all inputs", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            displayControl.autoPinToTopLayoutGuideOfViewController(self, withInset: 10)
            displayControl.autoAlignAxisToSuperviewAxis(.Vertical)
            displayControl.autoSetDimension(.Width, toSize: 200)
            displayControl.autoSetDimension(.Height, toSize: 30)
            
            searchView.autoPinEdge(.Top, toEdge: .Bottom, ofView: displayControl, withOffset: 10)
            searchView.autoPinEdgeToSuperviewEdge(.Leading)
            searchView.autoPinEdgeToSuperviewEdge(.Trailing)
            searchView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            patientSearchView.autoPinEdge(.Top, toEdge: .Bottom, ofView: displayControl, withOffset: 10)
            patientSearchView.autoPinEdgeToSuperviewEdge(.Leading)
            patientSearchView.autoPinEdgeToSuperviewEdge(.Trailing)
            patientSearchView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            labelsView.autoPinEdgeToSuperviewEdge(.Top)
            labelsView.autoPinEdgeToSuperviewEdge(.Bottom)
            labelsView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20)
            
            inputsView.autoPinEdgeToSuperviewEdge(.Top)
            inputsView.autoPinEdgeToSuperviewEdge(.Bottom)
            inputsView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10)
            
            inputsView.autoPinEdge(.Leading, toEdge: .Trailing, ofView: labelsView)
            inputsView.autoMatchDimension(.Width, toDimension: .Width, ofView: labelsView, withMultiplier: 1.5)
            
            patientLabel.autoPinEdgeToSuperviewEdge(.Leading)
            patientLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            kinectLabel.autoPinEdgeToSuperviewEdge(.Leading)
            kinectLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            
            patientLabel.autoSetDimension(.Height, toSize: 24)
            kinectLabel.autoSetDimension(.Height, toSize: 24)
            patientLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 30)
            kinectLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: patientLabel, withOffset: 30)
            
            patientInput.autoPinEdgeToSuperviewMargin(.Leading)
            patientInput.autoPinEdgeToSuperviewMargin(.Trailing)
            kinectInput.autoPinEdgeToSuperviewMargin(.Leading)
            kinectInput.autoPinEdgeToSuperviewMargin(.Trailing)
            
            patientInput.autoSetDimension(.Height, toSize: 24)
            kinectInput.autoSetDimension(.Height, toSize: 24)
            patientInput.autoPinEdgeToSuperviewEdge(.Top, withInset: 30)
            kinectInput.autoPinEdge(.Top, toEdge: .Bottom, ofView: patientInput, withOffset: 30)
            
            patientSearchButton.autoAlignAxisToSuperviewAxis(.Vertical)
            patientSearchButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: kinectInput, withOffset: 30)
            patientSearchButton.autoSetDimension(.Height, toSize: 40)
            patientSearchButton.autoSetDimension(.Width, toSize: 100)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - View Model
    
    func bindViewModel() {
        searchView.rac_hidden <~ viewModel.timeSearchViewHidden
        patientSearchView.rac_hidden <~ viewModel.patientSearchViewHidden
        
        viewModel.displaySegmentIndex <~ displayControl
            .rac_signalForControlEvents(.ValueChanged)
            .toSignalProducer()
            .flatMapError { _ in SignalProducer<AnyObject?, NoError>(value: "Display Segment Error") }
            .map { sender in sender as! UISegmentedControl }
            .map { $0.selectedSegmentIndex }
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
            let alert = UIAlertController(title: "Error", message: "Enter a value for all inputs", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func inputsValid() -> Bool {
        for (_, value) in searchView.getInputs() {
            if value.isEmpty { return false }
        }
        return true
    }
}

