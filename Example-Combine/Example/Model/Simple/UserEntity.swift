//
//  UserEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreRepository
import FoundationExtInternal

struct UserEntity: Identifiable, Codable, Equatable {
    typealias IDType = String
    
    var _id: String = ""
    var email: String = ""
    var name: String = ""
    
    var id: IDType { _id }
}
