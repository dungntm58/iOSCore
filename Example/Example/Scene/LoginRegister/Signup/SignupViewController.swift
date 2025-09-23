//
//  SignupViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreMacros
import Combine
import CoreRedux

@SceneView
class SignupViewController: BaseViewController {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    
    @SceneDependencyReference var store: LoginStore?
    
    lazy var cancellables: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await store?.state
                .compactMap(\.error)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {
                    [weak self] error in
                    self?.onError(error)
                })
                .store(in: &cancellables)
        }
    }
    
    @IBAction func onSignup(_ sender: UIButton) {
        guard let userName = lbUsername.text, let password = lbPassword.text else {
            return
        }
        Task {
            await store?.dispatch(type: .register, payload: (userName, password))
        }
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
