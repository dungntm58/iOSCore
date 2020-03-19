//
//  TodoCollectionView.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreBase
import RxCoreList
import Toaster

class TodoCollectionView: BaseCollectionView, Appearant {
    
    func willAppear(_ animated: Bool) {
        _ = viewSource
    }
    
    var store: TodoStore? {
        (viewController as? TodoList2ViewController)?.scene?.store
    }
    
    override func initializeViewSource() -> DataViewSource? {
        TodoList2ViewSource(store: store)
    }
}
