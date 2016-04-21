//
//  SearchViewController.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/14/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    var searchView: SearchView!
    
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        searchView = SearchView.newAutoLayoutView()
        view.addSubview(searchView)
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            searchView.autoPinEdgesToSuperviewEdges()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
}

