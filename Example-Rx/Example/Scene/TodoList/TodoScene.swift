//
//  TodoScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase
import CoreRedux
import NSObject_Rx

protocol TodoSceneProtocol: Scenable {
    
}

class TodoScene: Scene, HasDisposeBag, TodoSceneProtocol {
    
    @SceneDependency var store = TodoStore()
    @SceneDependency var viewManager = ViewManager()
    
    init() {
        super.init()
        setup()
    }
    
    private func setup() {
        // setup views
        let tableScene = TodoTableScene()
        let gridScene = TodoGridScene()
        set(children: [tableScene, gridScene])
        guard let tableVC = tableScene.viewManager?.currentViewController,
              let gridVC = gridScene.viewManager?.currentViewController else { return }
        viewManager?.setChildViewControllers([tableVC, gridVC])
        
        // sync store
        store?
            .state
            .compactMap(\.newTodo)
            .distinctUntilChanged()
            .subscribe(onNext: {
                [weak tableScene, weak gridScene] state in
                tableScene?.store?.dispatch(type: .addNewTodo, payload: state)
                gridScene?.store?.dispatch(type: .addNewTodo, payload: state)
            })
            .disposed(by: disposeBag)
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
        init() {
            super.init(viewController: {
                let todoVC = AppStoryboard.main.viewController(of: TodoTabBarController.self)
                todoVC.modalPresentationStyle = .fullScreen
                return todoVC
            }())
        }
        
        func setChildViewControllers(_ viewControllers: [UIViewController]) {
            guard let tabBar = currentViewController as? UITabBarController else { return }
            tabBar.viewControllers = viewControllers
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
