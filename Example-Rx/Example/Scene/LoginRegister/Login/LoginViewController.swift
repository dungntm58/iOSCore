//
//  ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/6/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxSwift
import CoreBase

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @SceneReferenced var scene: LoginSceneProtocol?
    @SceneDependencyReferenced(keyPath: \LoginSceneProtocol.store) var store: LoginStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store?.state
            .compactMap(\.user)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.scene?.switch(to: TodoScene(), with: nil)
            })
            .disposed(by: rx.disposeBag)
        
        store?.state
            .compactMap(\.error)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { $0.onError($1) })
            .disposed(by: rx.disposeBag)
        
        btnLogin.rx.tap
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(lbUsername.rx.text.orEmpty.filter { !$0.isEmpty })
                { _, text in text }
            .withLatestFrom(lbPassword.rx.text.orEmpty.filter { !$0.isEmpty })
                { ($0, $1) }
            .withUnretained(self)
            .subscribe(onNext: { `self`, payload in
                self.store?.dispatch(type: .login, payload: payload)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}

