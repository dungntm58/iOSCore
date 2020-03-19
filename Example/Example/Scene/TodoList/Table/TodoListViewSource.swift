//
//  Core-CleanSwift-ExampleViewModel.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/13/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase
import RxCoreList
import RxCoreRedux
import DifferenceKit

class TodoListViewSource: BaseTableViewSource {
    weak var store: TodoStore?
    
    init(store: TodoStore?) {
        self.store = store
        var cell = CellModelType.nib(nibName: "TodoTableViewCell", bundle: nil).makeCell()
        cell.height = 80
        super.init(sections: [[cell].makeSection()], shouldAnimateLoading: true)
        
        let response = store?.state
            .filter { $0.error == nil && !$0.isLogout }
            .map { $0.list }
            .distinctUntilChanged()
            .share()
        
        response?
            .map { $0.hasNext }
            .distinctUntilChanged()
            .bind(to: rx.isAnimating)
            .disposed(by: disposeBag)
            
        response?
            .filter { !$0.isLoading }
            .map {
                response in
                if response.currentPage <= 1 {
                    return ListViewSourceModel(type: .initial, data: response.data, needsReload: true)
                } else {
                    return ListViewSourceModel(type: .addNew(at: .end(length: response.data.count)), data: response.data, needsReload: true)
                }
            }
            .bind(to: rx.model)
            .disposed(by: disposeBag)
    }
    
    override func bind(value: ViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath) {
        let item = value as! TodoEntity
        let dataCell = cell as! TodoTableViewCell
        
        dataCell.lbTime.text = item.createdAt.toISO()
        dataCell.lbTitle.text = item.title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store?.dispatch(type: .selectTodo, payload: indexPath.row)
    }
    
    override func reachToEnd() {
        let currentPage = store?.currentState.list.currentPage ?? 0
        store?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
    }
}
