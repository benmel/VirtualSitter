//
//  DataStore.swift
//  VirtualSitter
//
//  Created by Ben Meline on 4/26/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

class DataStore {
    
    private var data = [String]()
    
    init(data: [String]) {
        self.data = data
    }
    
    func dataAtRow(row: Int) -> String {
        return data[row]
    }
    
    func count() -> Int {
        return data.count
    }
}
