//
//  UserRepository.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import Combine
import CoreBase
import CoreRepository
import CoreRepositoryDataStore

protocol AuthRepository {
    func login(_ options: RequestOption) -> AnyPublisher<UserEntity, Error>
    func signup(_ options: RequestOption) -> AnyPublisher<UserEntity, Error>
}

class MockAuthRepository: AuthRepository {
    func login(_ options: RequestOption) -> AnyPublisher<UserEntity, Error> {
        Future { promise in
            promise(.success(.init(_id: "1", email: options.parameters?["email"] as? String ?? "test@abc.com", name: options.parameters?["email"] as? String ?? "test@abc.com")))
        }
        .delay(for: 0.2, scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    func signup(_ options: RequestOption) -> AnyPublisher<UserEntity, Error> {
        Future { promise in
            promise(.success(.init(_id: "1", email: options.parameters?["email"] as? String ?? "test@abc.com", name: options.parameters?["email"] as? String ?? "test@abc.com")))
        }
        .delay(for: 0.2, scheduler: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
}

class ImplAuthRepository: AuthRepository {
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
                return self.userDataStore.save(auth.user)
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
                return self.userDataStore.save(auth.user)
            })
            .eraseToAnyPublisher()
    }
}
