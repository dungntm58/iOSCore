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
import Combine

class TodoListViewController: BaseViewController {
    
    typealias TodoCell = TableView.Cell<Int, TodoEntity, TodoTableViewCell>
    typealias LoadingCell = TableView.LoadingCell
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl = UIRefreshControl()
    
    lazy var cancellables = Set<AnyCancellable>()
    
    var scene: TodoScene? {
        (tabBarController as? TodoTabBarController)?.scene
    }

    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let scene = scene else { return }
        
        let response = scene.store.state
            .filter { $0.error == nil && !$0.isLogout }
            .map(\.list)
            .removeDuplicates()
            .share()
        
        Publishers
            .CombineLatest(
                response
                    .map(\.hasNext)
                    .removeDuplicates(),
                response
                    .filter { !$0.isLoading }
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
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
            .store(in: &cancellables)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.scene?.store.dispatch(type: .load, payload: 0)
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
                            self?.scene?.store.dispatch(type: .selectTodo, payload: indexPath.row)
                        }))
            }
            viewModel.isAnimatedLoading ?
                LoadingCell()
                    .willDisplayHandler({
                        [weak self] view, indexPath in
                        guard let self = self else { return }
                        viewModel.isAnimatedLoading ? view.startAnimation() : view.stopAnimation()
                        
                        let currentPage = self.scene?.store.currentState.list.currentPage ?? 0
                        self.scene?.store.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
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
