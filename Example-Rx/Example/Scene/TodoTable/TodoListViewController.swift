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
import SwiftDate
import RxSwift

class TodoListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl = UIRefreshControl()
    
    @SceneDependencyReferenced var viewModel: TodoListViewModelProtocol?

    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }
        
        viewModel.todosObservable
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, response in
                self.viewSourceProvider.store.isAnimatedLoading = response.hasNext
                if !response.isLoading {
                    if response.currentPage == 0 {
                        self.viewSourceProvider.store.todos = response.data
                    } else {
                        self.viewSourceProvider.store.todos += response.data
                    }
                    self.refreshControl.endRefreshing()
                }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewAppeared { return }
        viewModel?.load(page: 1)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.viewModel?.load()
    }
    
    func createViewSourceProvider() -> TableView.ViewSourceProvider<TodoViewModel> {
        return .init(tableView: tableView, store: .init()) {
            tableView, viewModel in
            for (index, todo) in viewModel.todos.enumerated() {
                TableView.Cell(id: index, cellType: TodoTableViewCell.self, model: todo)
                    .handlers { model, view, _ in
                        view.lbTime.text = model?.createdAt.toString()
                        view.lbTitle.text = model?.title
                    }
                    didSelectHandler: { [weak self] indexPath in
                        self?.viewModel?.selectTodo(at: indexPath.row)
                    }
            }
            if viewModel.isAnimatedLoading {
                TableView.LoadingCell()
                    .willDisplayHandler { [weak self] view, indexPath in
                        guard let self = self else { return }
                        viewModel.isAnimatedLoading ? view.startAnimation() : view.stopAnimation()
                        
                        guard let currentPage = self.viewModel?.currentPage else { return }
                        self.viewModel?.load(page: currentPage + 1)
                    }
            }
        }
    }
}
