//
//  LoginRouter.swift
//  Core-CleanSwift_Example_Realm
//
//  Created by Robert Nguyen on 3/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import CoreBase

class LoginScene: Scene, HasViewManagable {
    @SceneDependency var store: LoginStore?
    @SceneDependency var viewManager: ViewManager?

    var cancellables = Set<AnyCancellable>()

    init(store: LoginStore = LoginStore(), viewManager: ViewManager = ViewManager()) {
        super.init()
        self.store = store
        self.viewManager = viewManager

        store.state
            .compactMap(\.user)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                [weak self] _ in
                self?.switch(to: TodoScene(), with: nil)
            })
            .store(in: &cancellables)
    }
    
    override func perform(with object: Any?) {
        viewManager?.show()
    }

    func changeLoginStore() {
        store = LoginStore()
    }
}

extension LoginScene {
    class ViewManager: CoreBase.ViewManager {
        init() {
            let vc = AppStoryboard.main.viewController(of: LoginViewController.self)
            super.init(viewController: {
                let vc = UINavigationController(rootViewController: vc)
                vc.modalPresentationStyle = .fullScreen
                return vc
            }())
        }
        
        func show() {
            if let navigationController = scene?.presentedViewManager?.currentViewController?.navigationController, let currentViewController {
                navigationController.pushViewController(currentViewController, animated: true)
            } else {
                scene?.presentedViewManager?.currentViewController?.present(rootViewController, animated: true)
            }
        }

        func navigateToSignUp() {
            let vc = AppStoryboard.main.viewController(of: SignupViewController.self)
            pushViewController(vc)
        }
    }
}
