//
//  ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/6/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase

class LoginViewController: BaseCleanViewController, LoginDisplayable {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
    weak var scene: LoginScene?
    
    private lazy var interactor: LoginInteractor = {
        let presenter = LoginPresenter(view: self)
        let interactor = LoginInteractor(presenter: presenter)
        
        return interactor
    }()

    @IBAction func onLogin(_ sender: UIButton) {
        guard let userName = lbUsername.text, let password = lbPassword.text else {
            return
        }
        
        interactor.login(userName: userName, password: password)
    }
    
    func didLoginSuccess() {
        scene?.navigate(to: TodoScene())
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}

