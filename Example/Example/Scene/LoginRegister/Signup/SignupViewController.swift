//
//  SignupViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase
import RxSwift

class SignupViewController: BaseViewController, ConnectedSceneBindableRef {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
    var scene: LoginScene?
    
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene?.store.state
            .compactMap { $0.user }
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.scene?.switch(to: TodoScene())
            })
            .disposed(by: disposeBag)
        
        scene?.store.state
            .compactMap { $0.error }
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] error in
                self?.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func onSignup(_ sender: UIButton) {
        guard let userName = lbUsername.text, let password = lbPassword.text else {
            return
        }
        
        scene?.store.dispatch(type: .register, payload: (userName, password))
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
