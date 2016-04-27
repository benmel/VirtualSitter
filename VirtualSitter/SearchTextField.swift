//
//  SearchTextField.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/27/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
    
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            gestureRecognizer.enabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
}
