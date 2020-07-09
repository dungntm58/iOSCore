//
//  TodoListViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreRedux
import CoreList
import RxSwift

class TodoListViewController: BaseViewController {
    
    typealias TodoCell = TableView.Cell<Int, TodoEntity, TodoTableViewCell>
    typealias LoadingCell = TableView.LoadingCell
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl = UIRefreshControl()
    
    @SceneStoreReferenced var store: TodoStore?

    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let store = store else { return }
        
        let response = store.state
            .filter { $0.error == nil && !$0.isLogout }
            .map(\.list)
            .distinctUntilChanged()
            .share()
        
        Observable
            .combineLatest(
                response
                    .map(\.hasNext)
                    .distinctUntilChanged(),
                response
                    .filter { !$0.isLoading }
            )
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] isAnimating, response in
                guard let self = self else { return }
                self.viewSourceProvider.store.isAnimatedLoading = isAnimating
                if response.currentPage == 0 {
                    self.viewSourceProvider.store.todos = response.data
                } else {
                    self.viewSourceProvider.store.todos += response.data
                }
                self.refreshControl.endRefreshing()
                self.viewSourceProvider.reload()
            })
            .disposed(by: rx.disposeBag)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.store?.dispatch(type: .load, payload: 0)
    }
    
    func createViewSourceProvider() -> TableView.ViewSourceProvider<TodoViewModel> {
        return .init(tableView: tableView, store: .init()) {
            tableView, viewModel in
            ForEach(viewModel.todos) {
                index, todo in
                TodoCell(id: index, model: todo)
                    .handlers(
                        bindingFunction: ({
                            model, view, _ in
                            view.lbTime.text = model?.createdAt.toString()
                            view.lbTitle.text = model?.title
                        }),
                        didSelectHandler: ({
                            [weak self] indexPath in
                            self?.store?.dispatch(type: .selectTodo, payload: indexPath.row)
                        }))
            }
            viewModel.isAnimatedLoading ?
                LoadingCell()
                    .willDisplayHandler({
                        [weak self] view, indexPath in
                        guard let self = self else { return }
                        viewModel.isAnimatedLoading ? view.startAnimation() : view.stopAnimation()
                        
                        let currentPage = self.store?.currentState.list.currentPage ?? 0
                        self.store?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
                    })
                : nil
        }
    }
}

extension TodoListViewController.TodoCell {
    init(id: ID, model: Model) {
        self.init(id: id, type: .nib(nibName: "TodoTableViewCell", bundle: nil), model: model)
    }
}
