//
//  TodoListViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreMacros
import CoreRedux
import CoreReduxList
import CoreList
import Combine
import SwiftDate

@SceneView
class TodoListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
#if os(iOS)
    lazy var refreshControl = UIRefreshControl()
#endif
    
    lazy var cancellables = Set<AnyCancellable>()
    
    @SceneDependencyReference var viewModel: TodoStore?

    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            guard let viewModel = await viewModel else { return }
            
            viewModel.state
                .filter { $0.error == nil && !$0.isLogout }
                .map(\.list)
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {
                    [weak self] response in
                    guard let self = self else { return }
                    self.viewSourceProvider.store.isAnimatedLoading = response.hasNext
                    if !response.isLoading {
                        if response.currentPage == 0 {
                            self.viewSourceProvider.store.todos = response.data
                        } else {
                            self.viewSourceProvider.store.todos += response.data
                        }
#if os(iOS)
                        self.refreshControl.endRefreshing()
#endif
                    }
                    self.viewSourceProvider.reload()
                })
                .store(in: &cancellables)
        }
#if os(iOS)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
#endif
    }
    
#if os(iOS)
    @objc func refreshData(_ sender: UIRefreshControl) {
        Task {
            await viewModel?.dispatch(type: .load, payload: 0)
        }
    }
#endif
    
    func createViewSourceProvider() -> TableView.ViewSourceProvider<TodoViewModel> {
        return .init(tableView: tableView, store: .init()) {
            tableView, viewModel in
            for (index, todo) in viewModel.todos.enumerated() {
                TableView.Cell(
                    id: index,
                    cellType: TodoTableViewCell.self,
                    type: .nib(nibName: "TodoTableViewCell", bundle: nil),
                    model: todo
                )
                .handlers { model, view, _ in
                    view.lbTime.text = model?.createdAt.toString()
                    view.lbTitle.text = model?.title
                }
                didSelectHandler: { [weak self] indexPath in
                    guard let self else { return }
                    Task {
                        await self.viewModel?.dispatch(type: .selectTodo, payload: indexPath.row)
                    }
                }
            }
            if viewModel.isAnimatedLoading {
                TableView.LoadingCell()
                    .willDisplayHandler { [weak self] view, indexPath in
                        guard let self = self else { return }
                        viewModel.isAnimatedLoading ? view.startAnimation() : view.stopAnimation()
                        
                        Task {
                            guard let viewModel = await self.viewModel else { return }
                            let currentPage = viewModel.currentState.list.currentPage ?? 0
                            viewModel.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
                        }
                    }
            }
        }
    }
}
