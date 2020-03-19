//
//  TodoList2ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase

class TodoList2ViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: TodoCollectionView!
    
    var scene: TodoScene? {
        (tabBarController as? TodoTabBarController)?.scene
    }
}
