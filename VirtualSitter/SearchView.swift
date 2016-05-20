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
    
    private var startTimeInput: SearchTextField!
    private var endTimeInput: SearchTextField!
    private var roomInput: SearchTextField!
    private var floorInput: SearchTextField!
    private var kinectInput: SearchTextField!
    private var buildingInput: SearchTextField!
    
    private var startTimePicker: UIDatePicker!
    private var endTimePicker: UIDatePicker!
    private var roomPicker: UIPickerView!
    private var floorPicker: UIPickerView!
    private var kinectPicker: UIPickerView!
    private var buildingPicker: UIPickerView!
    
    private var roomDataSource: PickerViewDataSource?
    private var roomDelegate: PickerViewDelegate?
    private var floorDataSource: PickerViewDataSource?
    private var floorDelegate: PickerViewDelegate?
    private var kinectDataSource: PickerViewDataSource?
    private var kinectDelegate: PickerViewDelegate?
    private var buildingDataSource: PickerViewDataSource?
    private var buildingDelegate: PickerViewDelegate?
    
    private var searchButton: UIButton!
    
    private let roomNotification = "RoomDidChange"
    private let floorNotification = "FloorDidChange"
    private let kinectNotification = "KinectDidChange"
    private let buildingNotification = "BuildingDidChange"
    
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
        setupPickers()
        addObservers()
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
        
        startTimeLabel.text = "Start Time"
        endTimeLabel.text = "End Time"
        roomLabel.text = "Room"
        floorLabel.text = "Floor"
        kinectLabel.text = "Kinect"
        buildingLabel.text = "Building"
        
        labelsView.addSubview(startTimeLabel)
        labelsView.addSubview(endTimeLabel)
        labelsView.addSubview(roomLabel)
        labelsView.addSubview(floorLabel)
        labelsView.addSubview(kinectLabel)
        labelsView.addSubview(buildingLabel)
    }
    
    func setupInputs() {
        inputsView = UIView.newAutoLayoutView()
        addSubview(inputsView)
        
        startTimeInput = SearchTextField.newAutoLayoutView()
        endTimeInput = SearchTextField.newAutoLayoutView()
        roomInput = SearchTextField.newAutoLayoutView()
        floorInput = SearchTextField.newAutoLayoutView()
        kinectInput = SearchTextField.newAutoLayoutView()
        buildingInput = SearchTextField.newAutoLayoutView()
        
        startTimeInput.backgroundColor = .whiteColor()
        endTimeInput.backgroundColor = .whiteColor()
        roomInput.backgroundColor = .whiteColor()
        floorInput.backgroundColor = .whiteColor()
        kinectInput.backgroundColor = .whiteColor()
        buildingInput.backgroundColor = .whiteColor()
        
        startTimeInput.delegate = self
        endTimeInput.delegate = self
        roomInput.delegate = self
        floorInput.delegate = self
        kinectInput.delegate = self
        buildingInput.delegate = self
        
        inputsView.addSubview(startTimeInput)
        inputsView.addSubview(endTimeInput)
        inputsView.addSubview(roomInput)
        inputsView.addSubview(floorInput)
        inputsView.addSubview(kinectInput)
        inputsView.addSubview(buildingInput)
    }
    
    func setupPickers() {        
        let toolbar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        
        startTimePicker = UIDatePicker()
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), forControlEvents: .ValueChanged)
        startTimeInput.inputView = startTimePicker
        startTimeInput.inputAccessoryView = toolbar
        
        endTimePicker = UIDatePicker()
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), forControlEvents: .ValueChanged)
        endTimeInput.inputView = endTimePicker
        endTimeInput.inputAccessoryView = toolbar
        
        roomPicker = UIPickerView()
        let roomDataStore = DataStore(data: ["Select a room", "1", "112", "218", "312", "1236"])
        roomDataSource = PickerViewDataSource(dataStore: roomDataStore)
        roomDelegate = PickerViewDelegate(dataStore: roomDataStore, notificationName: roomNotification)
        roomPicker.dataSource = roomDataSource
        roomPicker.delegate = roomDelegate
        roomInput.inputView = roomPicker
        roomInput.inputAccessoryView = toolbar
        
        floorPicker = UIPickerView()
        let floorDataStore = DataStore(data: ["Select a floor", "Floor 1", "Floor 2"])
        floorDataSource = PickerViewDataSource(dataStore: floorDataStore)
        floorDelegate = PickerViewDelegate(dataStore: floorDataStore, notificationName: floorNotification)
        floorPicker.dataSource = floorDataSource
        floorPicker.delegate = floorDelegate
        floorInput.inputView = floorPicker
        floorInput.inputAccessoryView = toolbar
        
        kinectPicker = UIPickerView()
        let kinectDataStore = DataStore(data: ["Select a Kinect", "1", "2"])
        kinectDataSource = PickerViewDataSource(dataStore: kinectDataStore)
        kinectDelegate = PickerViewDelegate(dataStore: kinectDataStore, notificationName: kinectNotification)
        kinectPicker.dataSource = kinectDataSource
        kinectPicker.delegate = kinectDelegate
        kinectInput.inputView = kinectPicker
        kinectInput.inputAccessoryView = toolbar

        buildingPicker = UIPickerView()
        let buildingDataStore = DataStore(data: ["Select a building", "Building 1", "Building 2", "Building 3", "Building 4"])
        buildingDataSource = PickerViewDataSource(dataStore: buildingDataStore)
        buildingDelegate = PickerViewDelegate(dataStore: buildingDataStore, notificationName: buildingNotification)
        buildingPicker.dataSource = buildingDataSource
        buildingPicker.delegate = buildingDelegate
        buildingInput.inputView = buildingPicker
        buildingInput.inputAccessoryView = toolbar
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomPickerChanged), name: roomNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(floorPickerChanged), name: floorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(kinectPickerChanged), name: kinectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(buildingPickerChanged), name: buildingNotification, object: nil)
    }
    
    func setupButton() {
        searchButton = UIButton(type: .Custom)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setTitle("Search", forState: .Normal)
        searchButton.backgroundColor = .redColor()
        searchButton.addTarget(self, action: #selector(searchButtonClicked), forControlEvents: .TouchUpInside)
        addSubview(searchButton)
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            
            [startTimeLabel, endTimeLabel, roomLabel, floorLabel, kinectLabel, buildingLabel].autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Leading, withFixedSize: 24, insetSpacing: true)
            
            [startTimeInput, endTimeInput, roomInput, floorInput, kinectInput, buildingInput].autoDistributeViewsAlongAxis(.Vertical, alignedTo: .Leading, withFixedSize: 24, insetSpacing: true)
            
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
    
    func startTimeChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = .ShortStyle
//        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        startTimeInput.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func endTimeChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = .ShortStyle
//        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        endTimeInput.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func searchButtonClicked(sender: UIButton!) {
        delegate?.searchButtonWasClicked(self, sender: sender)
    }
    
    func roomPickerChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let roomValue = userInfo["value"] as? String else { return }
        roomInput.text = roomValue
    }
    
    func floorPickerChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let floorValue = userInfo["value"] as? String else { return }
        floorInput.text = floorValue
    }
    
    func kinectPickerChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let kinectValue = userInfo["value"] as? String else { return }
        kinectInput.text = kinectValue
    }
    
    func buildingPickerChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let buildingValue = userInfo["value"] as? String else { return }
        buildingInput.text = buildingValue
    }
    
    // MARK: - Input Values
    
    func getInputs() -> [String: String] {
        var inputValues = [String: String]()
        inputValues["startTime"] = startTimeInput.text
        inputValues["endTime"] = endTimeInput.text
        inputValues["room"] = roomInput.text
        inputValues["floor"] = floorInput.text
        inputValues["kinect"] = kinectInput.text
        inputValues["building"] = buildingInput.text
        return inputValues
    }
}

// MARK: - Text Field Delegate

extension SearchView: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
