//
//  AuthDto.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreRepository
import RxCoreBase

struct AuthDto: Decodable {
    let token: String
    let user: UserEntity!
    
    enum CodingKeys: String, CodingKey {
        case token = "accessToken"
        case user
    }
}
