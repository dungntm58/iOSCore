//
//  ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/6/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import Combine
import CoreMacros
import CombineCocoa
import CoreBase
import CoreRedux

@SceneView
class LoginViewController: BaseViewController {
    
    @IBOutlet weak var lbUsername: UITextField!
    @IBOutlet weak var lbPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    lazy var cancellables: Set<AnyCancellable> = .init()
    
    @SceneDependencyReference var store: LoginStore?
    @SceneDependencyReference var viewManager: LoginScene.ViewManager?
    
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
            
            btnLogin.tapPublisher
                .combineLatest(
                    lbUsername.textPublisher.compactMap { $0 }.filter { !$0.isEmpty }
                )
                .map { $1 }
                .combineLatest(
                    lbPassword.textPublisher.compactMap { $0 }.filter { !$0.isEmpty }
                )
                .sink { [weak self] payload in
                    guard let self else { return }
                    Task {
                        guard let store = await self.store else { return }
                        store.dispatch(type: .login, payload: payload)
                    }
                }
                .store(in: &cancellables)
            
            btnSignup.tapPublisher
                .sink { [weak self] in
                    guard let self else { return }
                    Task {
                        await self.viewManager?.navigateToSignUp()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func onError(_ error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
