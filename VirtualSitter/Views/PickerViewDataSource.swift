//
//  PickerViewDataSource.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/26/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit

class PickerViewDataSource: NSObject, UIPickerViewDataSource {
    
    private var dataStore: DataStore!
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        super.init()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataStore.count()
    }
}
