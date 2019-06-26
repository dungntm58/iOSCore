//
//  TodoTableView.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import CoreList
import CoreBase

class TodoTableView: BaseTableView, Appearant {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    func willAppear() {
        self.viewSource = TodoListViewSource(store: store)
    }
    
    func configure() {
    }
    
    var store: TodoStore? {
        return (viewController as? TodoListViewController)?.scene?.store
    }
}
