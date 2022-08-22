//
//  ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/6/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import CoreBase

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    lazy var cancellables: Set<AnyCancellable> = .init()
    
    @SceneDependencyReferenced var store: LoginStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store?.state
            .compactMap(\.user)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                [weak self] _ in
                self?.scene?.switch(to: TodoScene(), with: nil)
            })
            .store(in: &cancellables)
        
        store?.state
            .compactMap(\.error)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                [weak self] error in
                self?.onError(error)
            })
            .store(in: &cancellables)
        
        btnLogin.tapPublisher
            .combineLatest(
                lbUsername.textPublisher
                    .map { $0?.isEmpty ?? true }
                    .filter(!)
            )
            .map { $1 }
            .combineLatest(
                lbPassword.textPublisher
                    .map { $0?.isEmpty ?? true }
                    .filter(!)
            )
            .sink { [weak self] payload in
                self?.store?.dispatch(type: .login, payload: payload)
            }
            .store(in: &cancellables)
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}

