//
//  LoginPresenter.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import CoreBase

class LoginPresenter {
    weak var loginView: LoginDisplayable?
    
    init(view: LoginDisplayable) {
        self.loginView = view
    }
    
    func didLoginSuccess() {
        self.loginView?.didLoginSuccess()
    }
    
    func onError(_ error: Error) {
        
    }
}
