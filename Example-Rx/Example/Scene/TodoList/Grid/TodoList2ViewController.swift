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
import RxSwift

class TodoList2ViewController: BaseViewController {
    
    typealias TodoCell = CollectionView.Cell<Int, TodoEntity, TodoCollectionViewCell>
    typealias LoadingCell = CollectionView.LoadingCell
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refreshControl = UIRefreshControl()
    
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
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.scene?.store.dispatch(type: .load, payload: 0)
    }
    
    func createViewSourceProvider() -> CollectionView.ViewSourceProvider<TodoViewModel> {
        return .init(collectionView: collectionView, store: .init()) {
            collectionView, viewModel in
            ForEach(viewModel.todos) {
                index, todo in
                TodoCell(id: index, model: todo)
                    .size(CGSize(width: collectionView.frame.width, height: 60))
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
                LoadingCell(size: CGSize(width: collectionView.frame.width, height: 60))
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

extension TodoList2ViewController.TodoCell {
    init(id: ID, model: Model) {
        self.init(id: id, type: .nib(nibName: "TodoCollectionViewCell", bundle: nil), model: model)
    }
}
