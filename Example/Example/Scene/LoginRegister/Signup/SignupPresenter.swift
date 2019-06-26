//
//  SignupPresenter.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import CoreBase

class SignupPresenter {
    weak var signupView: SignupDisplayable?
    
    init(view: SignupDisplayable) {
        self.signupView = view
    }
    
    func didSignupSuccess() {
        self.signupView?.didSignupSuccess()
    }
    
    func onError(_ error: Error) {
        
    }
}
