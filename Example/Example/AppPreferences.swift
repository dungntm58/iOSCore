//
//  AppPreferences.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
//import Valet

class AppPreferences {
    static let instance = AppPreferences()

//    private let valet: Valet
    private let userDefaults: UserDefaults
    
    private init() {
        userDefaults = UserDefaults.standard
//        valet = Valet.valet(with: Identifier(nonEmpty: Bundle.main.bundleIdentifier!)!, accessibility: .whenUnlocked)
//        token = valet.string(forKey: Key.authenToken.rawValue)
    }
    
    enum Key: String {
        case authenToken = "AuthenToken"
    }
    
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Key.authenToken.rawValue)
        }
        get {
            UserDefaults.standard.string(forKey: Key.authenToken.rawValue)
        }
    }
    
//    var token: String? {
//        didSet {
//            if let token = token {
//                valet.set(string: token, forKey: Key.authenToken.rawValue)
//            } else {
//                valet.removeObject(forKey: Key.authenToken.rawValue)
//            }
//        }
//    }
}
