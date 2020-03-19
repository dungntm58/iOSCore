//
//  TodoTableView.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreList
import RxCoreBase

class TodoTableView: BaseTableView, Appearant {
    func willAppear(_ animated: Bool) {
        _ = viewSource
    }
    
    var store: TodoStore? {
        (viewController as? TodoListViewController)?.scene?.store
    }
    
    override func initializeViewSource() -> BaseTableView.DataViewSource? {
        TodoListViewSource(store: store)
    }
}
