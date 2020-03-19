//
//  LoginStore.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import RxCoreRedux
import RxSwift

class LoginStore: Store<LoginReducer.Action, LoginReducer.State> {
    init() {
        super.init(reducer: LoginReducer(), initialState: State())
        inject(
            LoginEpic().apply,
            RegisterEpic().apply
        )
    }
}
