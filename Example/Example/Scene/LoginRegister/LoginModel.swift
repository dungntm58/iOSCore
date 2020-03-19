//
//  LoginModel.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import RxCoreRedux

enum Login {
    enum LoginActionType: ErrorActionType {
        static var receiveError: LoginActionType { ._error }
        
        case login
        case register
        case success
        case _error
    }
    
    struct Action: Actionable {
        typealias ActionType = LoginActionType
        
        let type: ActionType
        let payload: Any
    }
    
    struct State: Statable {
        let error: Error?
        let user: UserEntity?
        
        init(error: Error? = nil, user: UserEntity? = nil) {
            self.error = error
            self.user = user
        }
    }
}
