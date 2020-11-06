//
//  TodoList2ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreRedux
import CoreList
import SwiftDate
import RxSwift

class TodoList2ViewController: BaseViewController {
    
    typealias TodoCell = CollectionView.Cell<Int, TodoEntity, TodoCollectionViewCell>
    typealias LoadingCell = CollectionView.LoadingCell
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refreshControl = UIRefreshControl()
    
    @SceneDependencyReferenced var store: TodoGridStore?
    
    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let store = store else { return }
        
        store.state
            .filter { $0.error == nil && !$0.isLogout }
            .map(\.list)
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] response in
                guard let self = self else { return }
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
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewAppeared { return }
        store?.dispatch(type: .load, payload: Payload.List.Request(page: 1, cancelRunning: false))
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.store?.dispatch(type: .load, payload: 0)
    }
    
    func createViewSourceProvider() -> CollectionView.ViewSourceProvider<TodoViewModel> {
        return .init(collectionView: collectionView, store: .init()) {
            collectionView, viewModel in
            ForEach(viewModel.todos) {
                index, todo in
                TodoCell(id: index, model: todo)
                    .hasFixedSize(true)
                    .handlers(
                        bindingFunction: ({
                            model, view, _ in
                            view.lbTime.text = model?.createdAt.toString()
                            view.lbTitle.text = model?.title
                        }),
                        sizeEstimationHandler: ({
                            _, collectionView in
                            CGSize(width: collectionView.frame.width, height: 60)
                        }),
                        didSelectHandler: ({
                            [weak self] indexPath in
                            self?.store?.dispatch(type: .selectTodo, payload: indexPath.row)
                        }))
            }
            viewModel.isAnimatedLoading ??
                LoadingCell(size: CGSize(width: collectionView.frame.width, height: 60))
                    .willDisplayHandler({
                        [weak self] view, indexPath in
                        guard let self = self else { return }
                        viewModel.isAnimatedLoading ? view.startAnimation() : view.stopAnimation()
                        
                        guard let currentPage = self.store?.currentState.list.currentPage else { return }
                        self.store?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
                    })
        }
    }
}

extension TodoList2ViewController.TodoCell {
    init(id: ID, model: Model) {
        self.init(id: id, type: .nib(nibName: "TodoCollectionViewCell", bundle: nil), model: model)
    }
}
