//
//  TodoEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import DifferenceKit
import CoreRequest
import CoreBase

struct TodoEntity: Identifiable, Decodable, Equatable {
    typealias IDType = String
    
    var _id: String = ""
    var title: String = ""
    var completed: Bool = false
    var owner: String = ""
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case _id
        case title
        case completed
        case owner
        case createdAt = "created"
    }
    
    init(title: String) {
        self.title = title
    }
    
    var id: String {
        return _id
    }
    
    func toLiteralDictionary() -> [String: Any] {
        return [
            "title": title
        ]
    }
}
