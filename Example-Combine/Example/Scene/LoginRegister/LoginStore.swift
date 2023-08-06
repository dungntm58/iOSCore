//
//  LoginStore.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import Foundation
import CoreRedux
import Combine

class LoginStore: Store<LoginReducer.Action, LoginReducer.State, DispatchQueue> {
    init() {
        super.init(reducer: LoginReducer(), initialState: State(), scheduler: .global())
        inject(
            LoginEpic().apply,
            RegisterEpic().apply
        )
        activate()
    }
}
