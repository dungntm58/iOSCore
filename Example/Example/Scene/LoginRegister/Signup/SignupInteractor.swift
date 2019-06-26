//
//  SignupInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/15/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxSwift

class SignupInteractor: AppInteractor {
    
    let presenter: SignupPresenter
    let worker: UserWorker
    
    init(presenter: SignupPresenter) {
        self.presenter = presenter
        self.worker = UserWorker()
        super.init()
    }
    
    func signup(userName: String, password: String) {
        worker.signup(userName: userName, password: password)
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe (
                onNext: {
                    _ in
                    self.presenter.didSignupSuccess()
                },
                onError: self.onError
            ).disposed(by: disposeBag)
    }
    
    override func onError(_ error: Error) {
        presenter.onError(error)
    }
}
