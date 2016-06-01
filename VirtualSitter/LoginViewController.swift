//
//  LoginViewController.swift
//  VirtualSitter
//
//  Created by Ben Meline on 5/24/16.
//  Copyright © 2016 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout
import ReactiveCocoa

class LoginViewController: UIViewController {
    
    private var viewModel: LoginViewModel!
    
    private var loginView: UIView!
    private var registrationView: UIView!
    
    private var emailInput: UITextField!
    private var passwordInput: UITextField!
    private var registrationEmailInput: UITextField!
    private var registrationPasswordInput: UITextField!
    private var registrationPasswordConfirmationInput: UITextField!
    
    private var loginButton: UIButton!
    private var registrationButton: UIButton!
    private var switchLoginButton: UIButton!
    private var switchRegistrationButton: UIButton!
    
    private var didSetupConstraints = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        setupView()
        view.setNeedsUpdateConstraints()
        bindViewModel()
    }
    
    func setupView() {
        view.backgroundColor = UIColor(red: 0.85, green: 0.82, blue: 0.91, alpha: 1.0)
        setupLoginView()
        setupRegistrationView()
        setupInputs()
        setupButtons()
    }
    
    func setupLoginView() {
        loginView = UIView.newAutoLayoutView()
        view.addSubview(loginView)
    }
    
    func setupRegistrationView() {
        registrationView = UIView.newAutoLayoutView()
        view.addSubview(registrationView)
    }
    
    func setupInputs() {
        emailInput = UITextField.newAutoLayoutView()
        passwordInput = UITextField.newAutoLayoutView()
        registrationEmailInput = UITextField.newAutoLayoutView()
        registrationPasswordInput = UITextField.newAutoLayoutView()
        registrationPasswordConfirmationInput = UITextField.newAutoLayoutView()
        
        configureEmailInput(emailInput)
        configurePasswordInput(passwordInput, placeholder: "Password")
        configureEmailInput(registrationEmailInput)
        configurePasswordInput(registrationPasswordInput, placeholder: "Password")
        configurePasswordInput(registrationPasswordConfirmationInput, placeholder: "Confirm Password")

        loginView.addSubview(emailInput)
        loginView.addSubview(passwordInput)
        
        registrationView.addSubview(registrationEmailInput)
        registrationView.addSubview(registrationPasswordInput)
        registrationView.addSubview(registrationPasswordConfirmationInput)
    }
    
    func configureEmailInput(textField: UITextField) {
        textField.backgroundColor = .whiteColor()
        textField.layer.cornerRadius = 4
        textField.placeholder = "Email"
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .EmailAddress
        
        let spacer = UIView(frame: CGRect(x:0, y:0, width:5, height:0))
        textField.leftViewMode = .Always
        textField.leftView = spacer
    }
    
    func configurePasswordInput(textField: UITextField, placeholder: String) {
        textField.backgroundColor = .whiteColor()
        textField.layer.cornerRadius = 4
        textField.placeholder = placeholder
        textField.secureTextEntry = true
        
        let spacer = UIView(frame: CGRect(x:0, y:0, width:5, height:0))
        textField.leftViewMode = .Always
        textField.leftView = spacer
    }
    
    func setupButtons() {
        loginButton = UIButton(type: .Custom)
        registrationButton = UIButton(type: .Custom)
        switchLoginButton = UIButton(type: .Custom)
        switchRegistrationButton = UIButton(type: .Custom)
        
        configureButton(loginButton, title: "Login")
        configureButton(registrationButton, title: "Register")
        configureButton(switchLoginButton, title: "Register new user")
        configureButton(switchRegistrationButton, title: "Login existing user")
        
        loginView.addSubview(loginButton)
        registrationView.addSubview(registrationButton)
        loginView.addSubview(switchLoginButton)
        registrationView.addSubview(switchRegistrationButton)
    }
    
    func configureButton(button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, forState: .Normal)
        button.backgroundColor = UIColor(red: 0.6, green: 0, blue: 1, alpha: 1)
    }
    
    // MARK: - View Model
    
    func bindViewModel() {
        loginView.rac_hidden <~ viewModel.loginViewHidden
        registrationView.rac_hidden <~ viewModel.registrationViewHidden
        
        viewModel.loginEmail <~ emailInput.rac_text
        viewModel.loginPassword <~ passwordInput.rac_text
        viewModel.registrationEmail <~ registrationEmailInput.rac_text
        viewModel.registrationPassword <~ registrationPasswordInput.rac_text
        viewModel.registrationPasswordConfirmation <~ registrationPasswordConfirmationInput.rac_text
        
        loginButton
            .rac_signalForControlEvents(.TouchUpInside)
            .toSignalProducer()
            .startWithNext { [weak self] _ in
                self?.viewModel.login()
            }

        registrationButton
            .rac_signalForControlEvents(.TouchUpInside)
            .toSignalProducer()
            .startWithNext { [weak self] _ in
                if let viewModel = self?.viewModel {
                    viewModel.canRegister() ? viewModel.register() : self?.showAlert("Passwords don't match")
                }
            }
        
        switchLoginButton
            .rac_signalForControlEvents(.TouchUpInside)
            .toSignalProducer()
            .startWithNext { [weak self] _ in
                self?.viewModel.switchView()
            }
        
        switchRegistrationButton
            .rac_signalForControlEvents(.TouchUpInside)
            .toSignalProducer()
            .startWithNext { [weak self] _ in
                self?.viewModel.switchView()
        }

        viewModel.successfulLogin.producer
            .observeOn(UIScheduler())
            .skip(1) // don't show error before view is shown
            .startWithNext { [weak self] next in
                next ? self?.dismissViewControllerAnimated(true, completion: nil) : self?.showAlert("Login failed")
            }
        
        viewModel.successfulRegistration.producer
            .observeOn(UIScheduler())
            .skip(1) // don't show error before view is shown
            .startWithNext { [weak self] next in
                next ? self?.dismissViewControllerAnimated(true, completion: nil) : self?.showAlert("Registration failed")
            }
    }
    
    // MARK: Alert
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Layout
        
    override func updateViewConstraints() {
        if !didSetupConstraints {
            loginView.autoPinEdgeToSuperviewEdge(.Top, withInset: 100)
            loginView.autoPinEdgeToSuperviewEdge(.Leading)
            loginView.autoPinEdgeToSuperviewEdge(.Trailing)
            loginView.autoSetDimension(.Height, toSize: 300)
            
            registrationView.autoPinEdgeToSuperviewEdge(.Top, withInset: 100)
            registrationView.autoPinEdgeToSuperviewEdge(.Leading)
            registrationView.autoPinEdgeToSuperviewEdge(.Trailing)
            registrationView.autoSetDimension(.Height, toSize: 300)
            
            emailInput.autoPinEdgeToSuperviewEdge(.Top)
            emailInput.autoAlignAxisToSuperviewAxis(.Vertical)
            passwordInput.autoPinEdge(.Top, toEdge: .Bottom, ofView: emailInput, withOffset: 15)
            passwordInput.autoAlignAxisToSuperviewAxis(.Vertical)
            
            emailInput.autoSetDimension(.Width, toSize: 180)
            emailInput.autoSetDimension(.Height, toSize: 30)
            passwordInput.autoSetDimension(.Width, toSize: 180)
            passwordInput.autoSetDimension(.Height, toSize: 30)
            
            registrationEmailInput.autoPinEdgeToSuperviewEdge(.Top)
            registrationEmailInput.autoAlignAxisToSuperviewAxis(.Vertical)
            registrationPasswordInput.autoPinEdge(.Top, toEdge: .Bottom, ofView: registrationEmailInput, withOffset: 15)
            registrationPasswordInput.autoAlignAxisToSuperviewAxis(.Vertical)
            registrationPasswordConfirmationInput.autoPinEdge(.Top, toEdge: .Bottom, ofView: registrationPasswordInput, withOffset: 15)
            registrationPasswordConfirmationInput.autoAlignAxisToSuperviewAxis(.Vertical)
            
            registrationEmailInput.autoSetDimension(.Width, toSize: 180)
            registrationEmailInput.autoSetDimension(.Height, toSize: 30)
            registrationPasswordInput.autoSetDimension(.Width, toSize: 180)
            registrationPasswordInput.autoSetDimension(.Height, toSize: 30)
            registrationPasswordConfirmationInput.autoSetDimension(.Width, toSize: 180)
            registrationPasswordConfirmationInput.autoSetDimension(.Height, toSize: 30)
            
            loginButton.autoAlignAxisToSuperviewAxis(.Vertical)
            loginButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: passwordInput, withOffset: 20)
            loginButton.autoSetDimension(.Height, toSize: 35)
            loginButton.autoSetDimension(.Width, toSize: 180)
            
            switchLoginButton.autoAlignAxisToSuperviewAxis(.Vertical)
            switchLoginButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: loginButton, withOffset: 10)
            switchLoginButton.autoSetDimension(.Height, toSize: 35)
            switchLoginButton.autoSetDimension(.Width, toSize: 180)
            
            registrationButton.autoAlignAxisToSuperviewAxis(.Vertical)
            registrationButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: registrationPasswordConfirmationInput, withOffset: 20)
            registrationButton.autoSetDimension(.Height, toSize: 35)
            registrationButton.autoSetDimension(.Width, toSize: 180)
            
            switchRegistrationButton.autoAlignAxisToSuperviewAxis(.Vertical)
            switchRegistrationButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: registrationButton, withOffset: 10)
            switchRegistrationButton.autoSetDimension(.Height, toSize: 35)
            switchRegistrationButton.autoSetDimension(.Width, toSize: 180)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
}
