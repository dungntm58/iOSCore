//
//  SignupViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase

class SignupViewController: BaseCleanViewController, SignupDisplayable {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
//    weak var scene: LoginScene?
    
    private lazy var interactor: SignupInteractor = {
        let presenter = SignupPresenter(view: self)
        return SignupInteractor(presenter: presenter)
    }()
    
    @IBAction func onSignup(_ sender: UIButton) {
        guard let userName = lbUsername.text, let password = lbPassword.text else {
            return
        }
        
        interactor.signup(userName: userName, password: password)
    }
    
    func didSignupSuccess() {
//        router.navigate(to: TodoScene())
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
