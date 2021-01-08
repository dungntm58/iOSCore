//
//  LoginReducer.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import CoreRedux
import RxSwift

class LoginReducer: Reducible {
    typealias State = Login.State
    typealias Action = Login.Action
    
    func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .success:
            return State(user: action.payload as? UserEntity)
        case .receiveError:
            return State(error: action.payload as? Error)
        default:
            return currentState
        }
    }
}
