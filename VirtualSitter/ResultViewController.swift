//
//  ResultViewController.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/21/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class ResultViewController: UIViewController {

    var resultText = ""
    private var resultLabel: UILabel!
    
    private var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel = UILabel.newAutoLayoutView()
        resultLabel.text = resultText
        view.addSubview(resultLabel)
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            resultLabel.autoPinToTopLayoutGuideOfViewController(self, withInset: 20)
            resultLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
}
