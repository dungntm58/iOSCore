//
//  SignupViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import RxSwift

class SignupViewController: BaseViewController {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
    @SceneReferenced var scene: LoginScene?
    @SceneStoreReferenced var store: LoginStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store?.state
            .compactMap(\.user)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.scene?.switch(to: TodoScene(), with: nil)
            })
            .disposed(by: rx.disposeBag)
        
        store?.state
            .compactMap(\.error)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] error in
                self?.onError(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func onSignup(_ sender: UIButton) {
        guard let userName = lbUsername.text, let password = lbPassword.text else {
            return
        }
        
        store?.dispatch(type: .register, payload: (userName, password))
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
