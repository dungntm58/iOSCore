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
import CoreRedux

class TodoScene: Scene, HasViewManagable {
    @SceneDependency var store: TodoStore?
    @SceneDependency var viewManager: ViewManager?

    var cancellables = Set<AnyCancellable>()

    init(store: TodoStore = TodoStore(), viewManager: ViewManager = ViewManager()) {
        super.init()
        self.store = store
        self.viewManager = viewManager

        store
            .state
            .filter { $0.error == nil }
            .map(\.isLogout)
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                [weak self] _ in
                self?.detach(with: nil)
            })
            .store(in: &cancellables)
    }

    override func perform(with object: Any?) {
        viewManager?.show()
    }
    
    override func onDetach() {
        viewManager?.dismiss()
    }
}

extension TodoScene {
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
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
        
        func showTodoDetail() {
            let vc = AppStoryboard.main.viewController(of: TodoDetailViewController.self)
            vc.modalPresentationStyle = .fullScreen
            pushViewController(vc)
        }
    }
}
