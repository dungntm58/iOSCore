//
//  TodoScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase
import CoreRedux

class TodoScene: ConnectableViewableScene<TodoStore>, Dispatchable {
    typealias Action = TodoStore.Action
    
    lazy var navigationController: UINavigationController = {
        let vc = UINavigationController(rootViewController: viewController)
        return vc
    }()
    
    init() {
        let todoVC = AppStoryboard.main.viewController(of: TodoTabBarController.self)
        super.init(store: TodoStore(), viewController: todoVC)
        todoVC.scene = self
    }

    override func perform() {
        let visibleViewController = nearestViewableScene?.viewController
        if let navigationController = visibleViewController?.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
        else {
            visibleViewController?.present(navigationController, animated: true)
        }
    }
}
