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
    
    @SceneRef var scene: LoginScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene?.store.state
            .compactMap(\.user)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.scene?.switch(to: TodoScene(), with: nil)
            })
            .disposed(by: rx.disposeBag)
        
        scene?.store.state
            .compactMap(\.error)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] error in
                self?.onError(error)
            })
            .disposed(by: rx.disposeBag)
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

