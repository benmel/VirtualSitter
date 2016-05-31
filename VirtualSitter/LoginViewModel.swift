//
//  LoginViewModel.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/25/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct LoginViewModel {
    
    let loginViewHidden = MutableProperty<Bool>(false)
    let registrationViewHidden = MutableProperty<Bool>(true)
    
    func switchView() {
        loginViewHidden.swap(!loginViewHidden.value)
        registrationViewHidden.swap(!registrationViewHidden.value)
    }
}