//
//  Entity.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 3/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreData

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}
