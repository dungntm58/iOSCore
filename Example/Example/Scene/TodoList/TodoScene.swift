//
//  TodoScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import CoreBase
import CoreMacros
import CoreRedux

@Scene
actor TodoScene {
    var store: TodoStore
    @AsyncInit
    var viewManager: ViewManager

    var cancellables = Set<AnyCancellable>()

    init(store: TodoStore = .init(), viewManager: ViewManager? = nil) {
        self.store = store
        self._viewManager = AsyncInit {
            if let viewManager {
                return viewManager
            }
            return await ViewManager()
        }
        Task {
            await setupBindings()
        }
    }

    private func setupBindings() {
        store
            .state
            .filter { $0.error == nil }
            .map(\.isLogout)
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.detach(with: nil)
                }
            })
            .store(in: &cancellables)
    }

    func perform(with object: Any?) async {
        await viewManager.show()
    }
    
    func onDetach() async {
        await viewManager.dismiss()
    }
}

extension TodoScene {
    @SceneDependency
    class ViewManager: CoreBase.ViewManager {
        lazy var window = UIWindow(frame: UIScreen.main.bounds)

        init() {
            super.init(viewController: {
                let todoVC = AppStoryboard.main.viewController(of: TodoTabBarController.self)
                todoVC.modalPresentationStyle = .fullScreen
                return todoVC
            }())
        }

        func show() {
            let navigationController: UINavigationController = {
                let vc = UINavigationController(rootViewController: rootViewController)
                vc.modalPresentationStyle = .fullScreen
                return vc
            }()

            if let visibleViewController = scene?.presentedViewManager?.currentViewController {
                visibleViewController.present(navigationController, animated: true)
            } else {
                getCurrentWindow()?.rootViewController = navigationController
            }
        }
        
        func showTodoDetail() {
            let vc = AppStoryboard.main.viewController(of: TodoDetailViewController.self)
            vc.modalPresentationStyle = .fullScreen
            push(vc)
        }
    }
}
