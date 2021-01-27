//
//  Constant.swift
//  Core-CleanSwift_Example_Realm
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

enum Constant {
    enum Error {
        static let errorDecodable = NSError(domain: "Decodable", code: 990, userInfo: [
            NSLocalizedDescriptionKey: "Fail to decode"
        ])
        
        static let errorEmptyDecodable = NSError(domain: "Decodable", code: 997, userInfo: [
            NSLocalizedDescriptionKey: "Data is empty"
        ])
    }
}
