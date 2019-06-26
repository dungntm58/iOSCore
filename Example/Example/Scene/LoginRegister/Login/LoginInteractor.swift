//
//  LoginInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/9/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxSwift

class LoginInteractor: AppInteractor {
    
    let loginPresenter: LoginPresenter
    let worker: UserWorker
    
    init(presenter: LoginPresenter) {
        self.loginPresenter = presenter
        self.worker = UserWorker()
        super.init()
    }
    
    func login(userName: String, password: String) {
        worker.login(userName: userName, password: password)
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe (
                onNext: {
                    _ in
                    self.loginPresenter.didLoginSuccess()
                },
                onError: self.onError
            ).disposed(by: disposeBag)
    }
    
    override func onError(_ error: Error) {
        loginPresenter.onError(error)
    }
}
