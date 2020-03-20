//
//  LoginStore.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import CoreRedux
import Combine

class LoginStore: Store<LoginReducer.Action, LoginReducer.State, RunLoop> {
    init() {
        super.init(reducer: LoginReducer(), initialState: State(), scheduler: .main)
        inject(
            LoginEpic().apply,
            RegisterEpic().apply
        )
    }
}
