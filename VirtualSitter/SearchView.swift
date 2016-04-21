//
//  SearchView.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/20/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

protocol SearchViewDelegate: class {
    func searchButtonWasClicked(searchView: SearchView, sender: UIButton!)
}

class SearchView: UIView {

    // MARK: - Views
    
    private var backgroundView: UIView!
    private var labelsView: UIView!
    private var inputsView: UIView!
    private var tapRecognizer: UITapGestureRecognizer!
    
    private var startTimeLabel: UILabel!
    private var endTimeLabel: UILabel!
    private var roomLabel: UILabel!
    private var floorLabel: UILabel!
    private var kinectLabel: UILabel!
    private var buildingLabel: UILabel!
    private var locationLabel: UILabel!
    
    private var startTimeInput: UITextField!
    private var endTimeInput: UITextField!
    private var roomInput: UITextField!
    private var floorInput: UITextField!
    private var kinectInput: UITextField!
    private var buildingInput: UITextField!
    private var locationInput: UITextField!
    
    private var searchButton: UIButton!
    
    weak var delegate: SearchViewDelegate?
    
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
    
    func initialize() {
        setupViews()
        setupLabels()
        setupInputs()
        setupButton()
    }
    
    func setupViews() {
        backgroundView = UIView.newAutoLayoutView()
        backgroundView.backgroundColor = UIColor(red: 0.85, green: 0.82, blue: 0.91, alpha: 1.0)
        addSubview(backgroundView)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapRecognizer)
    }
    
    func setupLabels() {
        labelsView = UIView.newAutoLayoutView()
        addSubview(labelsView)
        
        startTimeLabel = UILabel.newAutoLayoutView()
        endTimeLabel = UILabel.newAutoLayoutView()
        roomLabel = UILabel.newAutoLayoutView()
        floorLabel = UILabel.newAutoLayoutView()
        kinectLabel = UILabel.newAutoLayoutView()
        buildingLabel = UILabel.newAutoLayoutView()
        locationLabel = UILabel.newAutoLayoutView()
        
        startTimeLabel.text = "Start Time"
        endTimeLabel.text = "End Time"
        roomLabel.text = "Room"
        floorLabel.text = "Floor"
        kinectLabel.text = "Kinect"
        buildingLabel.text = "Building"
        locationLabel.text = "Location"
        
        labelsView.addSubview(startTimeLabel)
        labelsView.addSubview(endTimeLabel)
        labelsView.addSubview(roomLabel)
        labelsView.addSubview(floorLabel)
        labelsView.addSubview(kinectLabel)
        labelsView.addSubview(buildingLabel)
        labelsView.addSubview(locationLabel)
    }
    
    func setupInputs() {
        inputsView = UIView.newAutoLayoutView()
        addSubview(inputsView)
        
        startTimeInput = UITextField.newAutoLayoutView()
        endTimeInput = UITextField.newAutoLayoutView()
        roomInput = UITextField.newAutoLayoutView()
        floorInput = UITextField.newAutoLayoutView()
        kinectInput = UITextField.newAutoLayoutView()
        buildingInput = UITextField.newAutoLayoutView()
        locationInput = UITextField.newAutoLayoutView()
        
        startTimeInput.backgroundColor = .whiteColor()
        endTimeInput.backgroundColor = .whiteColor()
        roomInput.backgroundColor = .whiteColor()
        floorInput.backgroundColor = .whiteColor()
        kinectInput.backgroundColor = .whiteColor()
        buildingInput.backgroundColor = .whiteColor()
        locationInput.backgroundColor = .whiteColor()
        
        inputsView.addSubview(startTimeInput)
        inputsView.addSubview(endTimeInput)
        inputsView.addSubview(roomInput)
        inputsView.addSubview(floorInput)
        inputsView.addSubview(kinectInput)
        inputsView.addSubview(buildingInput)
        inputsView.addSubview(locationInput)
    }
    
    func setupButton() {
        searchButton = UIButton(type: .Custom)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setTitle("Search", forState: .Normal)
        searchButton.backgroundColor = .redColor()
        searchButton.addTarget(self, action: #selector(searchButtonClicked), forControlEvents: .TouchUpInside)
        addSubview(searchButton)
    }
    
    // MARK - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            backgroundView.autoPinEdgesToSuperviewEdges()
            
            labelsView.autoPinEdgeToSuperviewEdge(.Top, withInset: 70)
            labelsView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 70)
            labelsView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20)
            
            inputsView.autoPinEdgeToSuperviewEdge(.Top, withInset: 70)
            inputsView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 70)
            inputsView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10)
            
            inputsView.autoPinEdge(.Leading, toEdge: .Trailing, ofView: labelsView)
            inputsView.autoMatchDimension(.Width, toDimension: .Width, ofView: labelsView, withMultiplier: 1.5)
            
            startTimeLabel.autoPinEdgeToSuperviewEdge(.Leading)
            startTimeLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            endTimeLabel.autoPinEdgeToSuperviewEdge(.Leading)
            endTimeLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            roomLabel.autoPinEdgeToSuperviewEdge(.Leading)
            roomLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            floorLabel.autoPinEdgeToSuperviewEdge(.Leading)
            floorLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            kinectLabel.autoPinEdgeToSuperviewEdge(.Leading)
            kinectLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            buildingLabel.autoPinEdgeToSuperviewEdge(.Leading)
            buildingLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            locationLabel.autoPinEdgeToSuperviewEdge(.Leading)
            locationLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            
            startTimeInput.autoPinEdgeToSuperviewMargin(.Leading)
            startTimeInput.autoPinEdgeToSuperviewMargin(.Trailing)
            endTimeInput.autoPinEdgeToSuperviewMargin(.Leading)
            endTimeInput.autoPinEdgeToSuperviewMargin(.Trailing)
            roomInput.autoPinEdgeToSuperviewMargin(.Leading)
            roomInput.autoPinEdgeToSuperviewMargin(.Trailing)
            floorInput.autoPinEdgeToSuperviewMargin(.Leading)
            floorInput.autoPinEdgeToSuperviewMargin(.Trailing)
            kinectInput.autoPinEdgeToSuperviewMargin(.Leading)
            kinectInput.autoPinEdgeToSuperviewMargin(.Trailing)
            buildingInput.autoPinEdgeToSuperviewMargin(.Leading)
            buildingInput.autoPinEdgeToSuperviewMargin(.Trailing)
            locationInput.autoPinEdgeToSuperviewMargin(.Leading)
            locationInput.autoPinEdgeToSuperviewMargin(.Trailing)
            
            [startTimeLabel, endTimeLabel, roomLabel, floorLabel, kinectLabel, buildingLabel, locationLabel].autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Leading, withFixedSize: 20, insetSpacing: true)
            
            [startTimeInput, endTimeInput, roomInput, floorInput, kinectInput, buildingInput, locationInput].autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Leading, withFixedSize: 20, insetSpacing: true)
            
            searchButton.autoAlignAxisToSuperviewAxis(.Vertical)
            searchButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 20)
            searchButton.autoSetDimension(.Height, toSize: 40)
            searchButton.autoSetDimension(.Width, toSize: 100)
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    // MARK: - User Interaction
    
    func dismissKeyboard() {
        endEditing(true)
    }
    
    func searchButtonClicked(sender: UIButton!) {
        delegate?.searchButtonWasClicked(self, sender: sender)
    }
}
