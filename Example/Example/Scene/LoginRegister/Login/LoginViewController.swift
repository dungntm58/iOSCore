//
//  ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/6/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxSwift
import RxCoreBase

class LoginViewController: BaseViewController, ConnectedSceneBindableRef {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
    lazy var disposeBag = DisposeBag()
    
    var scene: LoginScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene?.store.state
            .compactMap { $0.user }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.scene?.switch(to: TodoScene())
            })
            .disposed(by: disposeBag)
        
        scene?.store.state
            .compactMap { $0.error }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] error in
                self?.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        guard let userName = lbUsername.text, let password = lbPassword.text else {
            return
        }
        
        scene?.store.dispatch(type: .login, payload: (userName, password))
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}

