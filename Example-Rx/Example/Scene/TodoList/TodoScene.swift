//
//  TodoScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase
import CoreRedux

class TodoScene: Scene {
    
    @SceneDependency var store = TodoStore()
    @SceneDependency var viewManager = ViewManager()

    override func perform(with object: Any?) {
        viewManager?.show()
    }
    
    override func onDetach() {
        viewManager?.dismiss()
    }
}

extension TodoScene {
    class ViewManager: CoreBase.ViewManager {
        init() {
            super.init(viewController: {
                let todoVC = AppStoryboard.main.viewController(of: TodoTabBarController.self)
                todoVC.modalPresentationStyle = .fullScreen
                return todoVC
            }())
        }
        
        func show() {
            let navigationController: UINavigationController = {
                let vc = UINavigationController(rootViewController: currentViewController)
                vc.modalPresentationStyle = .fullScreen
                return vc
            }()
            
            let visibleViewController = scene?.presentedViewManager?.currentViewController
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
}
