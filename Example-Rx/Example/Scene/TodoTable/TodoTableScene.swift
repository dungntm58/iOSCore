//
//  TodoTableScene.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreBase
import CoreRedux

class TodoTableScene: Scene {
    
    @SceneDependency var store = TodoListStore()
    @SceneDependency var viewManager = ViewManager()
    
    override func perform(with userInfo: Any?) {
        viewManager?.show()
    }
}

extension TodoTableScene {
    class ViewManager: CoreBase.ViewManager {
        init() {
            super.init(viewController: {
                let vc = AppStoryboard.main.viewController(of: TodoListViewController.self)
                return vc
            }())
        }
        
        func show() {
            currentViewController.tabBarController?.selectedIndex = 0
        }
    }
}
