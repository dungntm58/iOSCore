//
//  AppPreferences.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation

class AppPreferences {
    static let instance = AppPreferences()
    
    private init() {}
    
    private static let authenToken = "AuthenToken"
    
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: AppPreferences.authenToken)
        }
        get {
            return UserDefaults.standard.string(forKey: AppPreferences.authenToken)
        }
    }
}
