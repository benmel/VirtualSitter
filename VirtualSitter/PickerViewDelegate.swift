//
//  PickerViewDelegate.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/26/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit

class PickerViewDelegate: NSObject, UIPickerViewDelegate {
    
    private var dataStore: DataStore!
    private var notificationName: String!
    
    init(dataStore: DataStore, notificationName: String) {
        self.dataStore = dataStore
        self.notificationName = notificationName
        super.init()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataStore.dataAtRow(row)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // The first row is just a message
        let value = row > 0 ? dataStore.dataAtRow(row) : ""
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: ["value": value])
    }
}
