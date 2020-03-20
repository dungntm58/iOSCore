//
//  ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/6/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import Combine
import CoreBase

class LoginViewController: BaseViewController, ConnectedSceneBindableRef {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
    lazy var cancellables: Set<AnyCancellable> = .init()
    
    var scene: LoginScene?
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene?.store.state
            .compactMap { $0.user }
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] _ in
                self?.scene?.switch(to: TodoScene())
            })
            .store(in: &cancellables)
        
        scene?.store.state
            .compactMap { $0.error }
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] error in
                self?.onError(error)
            })
            .store(in: &cancellables)
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

