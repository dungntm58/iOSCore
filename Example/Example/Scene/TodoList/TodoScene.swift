//
//  TodoScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxCoreBase
import RxCoreRedux

class TodoScene: ConnectableViewableScene<TodoStore>, Dispatchable {
    typealias Action = TodoStore.Action
    
    lazy var navigationController: UINavigationController = {
        let vc = UINavigationController(rootViewController: currentViewController)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    convenience init() {
        let todoVC = AppStoryboard.main.viewController(of: TodoTabBarController.self)
        todoVC.modalPresentationStyle = .fullScreen
        self.init(store: TodoStore(), viewController: todoVC)
    }

    override func perform() {
        let visibleViewController = nearestViewable?.currentViewController
        if let navigationController = visibleViewController?.navigationController {
            navigationController.pushViewController(currentViewController, animated: true)
        }
        else {
            visibleViewController?.present(navigationController, animated: true)
        }
    }
    
    func showTodoDetail() {
        let vc = AppStoryboard.main.viewController(of: TodoDetailViewController.self)
        vc.modalPresentationStyle = .fullScreen
        present(vc)
    }
}
