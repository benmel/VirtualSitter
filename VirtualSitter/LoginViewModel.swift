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
    private let virtualSitterService = VirtualSitterService()
    
    let loginEmail = MutableProperty<String>("")
    let loginPassword = MutableProperty<String>("")
    
    let registrationEmail = MutableProperty<String>("")
    let registrationPassword = MutableProperty<String>("")
    let registrationPasswordConfirmation = MutableProperty<String>("")
    
    let successfulLogin = MutableProperty<Bool>(false)
    let successfulRegistration = MutableProperty<Bool>(false)
    
    let loginViewHidden = MutableProperty<Bool>(false)
    let registrationViewHidden = MutableProperty<Bool>(true)
    
    func switchView() {
        loginViewHidden.swap(!loginViewHidden.value)
        registrationViewHidden.swap(!registrationViewHidden.value)
    }
    
    func login() {
        successfulLogin <~ virtualSitterService.signalForLogin(loginEmail.value, password: loginPassword.value)
            .flatMapError { _ in return SignalProducer<Bool, NoError>(value: false) }
    }
    
    func register() {
        successfulRegistration <~ virtualSitterService.signalForRegistration(registrationEmail.value, password: registrationPassword.value)
            .flatMapError { _ in return SignalProducer<Bool, NoError>(value: false) }
    }
}