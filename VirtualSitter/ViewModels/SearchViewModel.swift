//
//  SearchViewModel.swift
//  VirtualSitter
//
//  Created by Ben Meline on 6/1/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct SearchViewModel {
    let displaySegmentIndex = MutableProperty<Int>(0)
    let timeSearchViewHidden = MutableProperty<Bool>(false)
    let patientSearchViewHidden = MutableProperty<Bool>(true)
    
    init() {
        displaySegmentIndex.producer.startWithSignal { signal,_ in
            timeSearchViewHidden <~ signal.map { $0 != 0 }
            patientSearchViewHidden <~ signal.map { $0 != 1 }
        }
    }
}
