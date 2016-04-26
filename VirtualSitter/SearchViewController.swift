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
}

// MARK: - Search View Delegate

extension SearchViewController: SearchViewDelegate {
    func searchButtonWasClicked(searchView: SearchView, sender: UIButton!) {
        performSegueWithIdentifier(resultsSegueIdentifier, sender: sender)
    }
}

