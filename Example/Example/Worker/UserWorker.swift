//
//  UserService.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreRepository

class UserWorker {
    let authRepository: AuthRepository
    
    init() {
        authRepository = AuthRepository()
    }
    
    struct RequestOption: RxCoreRepository.RequestOption {
        let userName: String
        let password: String
        
        var parameters: [String : Any]? {
            [
                "email": userName,
                "password": password
            ]
        }
    }
    
    func login(userName: String, password: String) -> Observable<UserEntity> {
        let options = UserWorker.RequestOption(userName: userName, password: password)
        return authRepository.login(options)
    }
    
    func signup(userName: String, password: String) -> Observable<UserEntity> {
        let options = UserWorker.RequestOption(userName: userName, password: password)
        return authRepository.signup(options)
    }
}
