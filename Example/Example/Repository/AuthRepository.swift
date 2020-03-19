//
//  UserRepository.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreBase
import RxCoreRepository

class AuthRepository {
    private let request: AuthRequest
    private let userDataStore: UserDataStore
    
    init() {
        request = AuthRequest()
        userDataStore = UserDataStore()
    }
    
    func login(_ options: RequestOption) -> Observable<UserEntity> {
        request
            .login(options)
            .map {
                response -> AuthDto in
                guard let data = response.result else {
                    throw Constant.Error.errorEmptyDecodable
                }
                return data
            }
            .flatMap {
                auth -> Observable<UserEntity> in
                AppPreferences.instance.token = auth.token
                return self.userDataStore.saveAsync(auth.user)
            }
    }
    
    func signup(_ options: RequestOption) -> Observable<UserEntity> {
        request
            .signup(options)
            .map {
                response -> AuthDto in
                guard let data = response.result else {
                    throw Constant.Error.errorEmptyDecodable
                }
                return data
            }
            .flatMap {
                auth -> Observable<UserEntity> in
                AppPreferences.instance.token = auth.token
                return self.userDataStore.saveAsync(auth.user)
            }
    }
}
