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
import CoreMacros
import CoreRedux

@Scene
actor LoginScene {
    var store: LoginStore
    @AsyncInit
    var viewManager: ViewManager

    var cancellables = Set<AnyCancellable>()

    init(store: LoginStore = .init(), viewManager: ViewManager? = nil) {
        self.store = store
        self._viewManager = AsyncInit {
            if let viewManager {
                return viewManager
            }
            return await ViewManager()
        }
        Task {
            await self.setupBindings()
        }
    }
    
    private func setupBindings() {
        self.store.state
            .compactMap(\.user)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.switch(to: TodoScene(), with: nil)
                }
            })
            .store(in: &cancellables)
    }
    
    func perform(with object: Any?) async {
        await viewManager.show()
    }

    func changeLoginStore() {
        store = LoginStore()
    }
}

extension LoginScene {
    @SceneDependency
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
            if let visibleViewController = scene?.presentedViewManager?.currentViewController {
                if let navigationController = visibleViewController.navigationController, let currentViewController {
                    navigationController.pushViewController(currentViewController, animated: true)
                } else {
                    visibleViewController.present(rootViewController, animated: true)
                }
            } else {
                var window = getCurrentWindow()
                if window == nil {
                    window = UIWindow()
                    window?.rootViewController = rootViewController
                    window?.makeKeyAndVisible()
                } else {
                    window?.rootViewController = rootViewController
                }
            }
        }

        func navigateToSignUp() {
            let vc = AppStoryboard.main.viewController(of: SignupViewController.self)
            push(vc)
        }
    }
}
