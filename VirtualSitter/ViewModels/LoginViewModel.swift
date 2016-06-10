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
    
    let loginStatus = MutableProperty<LoginStatus>(LoginStatus.Unattempted)
    let registrationStatus = MutableProperty<RegistrationStatus>(RegistrationStatus.Unattempted)
    
    let loginViewHidden = MutableProperty<Bool>(false)
    let registrationViewHidden = MutableProperty<Bool>(true)
    
    func clearInputs() {
        loginEmail.swap("")
        loginPassword.swap("")
        registrationEmail.swap("")
        registrationPassword.swap("")
        registrationPasswordConfirmation.swap("")
    }
    
    func showLogin() {
        loginViewHidden.swap(false)
        registrationViewHidden.swap(true)
    }
    
    func showRegistration() {
        loginViewHidden.swap(true)
        registrationViewHidden.swap(false)
    }
    
    func login() {
        loginStatus <~ virtualSitterService.signalForLogin(loginEmail.value, password: loginPassword.value)
            .flatMapError { _ in return SignalProducer<LoginStatus, NoError>(value: LoginStatus.Failed) }
    }
    
    func canRegister() -> Bool {
        return registrationPassword.value == registrationPasswordConfirmation.value
    }
    
    func register() {
        registrationStatus <~ virtualSitterService.signalForRegistration(registrationEmail.value, password: registrationPassword.value)
            .flatMapError { _ in return SignalProducer<RegistrationStatus, NoError>(value: RegistrationStatus.Failed) }
    }
}