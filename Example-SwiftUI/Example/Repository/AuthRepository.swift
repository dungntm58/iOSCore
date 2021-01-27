//
//  UserRepository.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Combine
import CoreRepository

class AuthRepository {
    private let request: AuthRequest
    private let userDataStore: UserDataStore
    
    init() {
        request = AuthRequest()
        userDataStore = UserDataStore()
    }
    
    func login(_ options: RequestOption) -> AnyPublisher<UserEntity, Error> {
        request
            .login(options)
            .tryMap {
                response -> AuthDto in
                guard let data = response.result else {
                    throw Constant.Error.errorEmptyDecodable
                }
                return data
            }
            .flatMap ({
                auth -> AnyPublisher<UserEntity, Error> in
                AppPreferences.instance.token = auth.token
                return self.userDataStore.saveAsync(auth.user)
            })
            .eraseToAnyPublisher()
    }
    
    func signup(_ options: RequestOption) -> AnyPublisher<UserEntity, Error> {
        request
            .signup(options)
            .tryMap {
                response -> AuthDto in
                guard let data = response.result else {
                    throw Constant.Error.errorEmptyDecodable
                }
                return data
            }
            .flatMap ({
                auth -> AnyPublisher<UserEntity, Error> in
                AppPreferences.instance.token = auth.token
                return self.userDataStore.saveAsync(auth.user)
            })
            .eraseToAnyPublisher()
    }
}
