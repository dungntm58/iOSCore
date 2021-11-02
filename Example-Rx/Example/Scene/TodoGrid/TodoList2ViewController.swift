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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refreshControl = UIRefreshControl()
    
    @SceneDependencyReferenced var viewModel: TodoListViewModelProtocol?
    
    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.todosObservable
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
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
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
    
    func createViewSourceProvider() -> CollectionView.ViewSourceProvider<TodoViewModel> {
        return .init(collectionView: collectionView, store: .init()) {
            collectionView, viewModel in
            for (index, todo) in viewModel.todos.enumerated() {
                CollectionView.Cell(
                    id: index,
                    cellType: TodoCollectionViewCell.self,
                    type: .nib(nibName: "TodoCollectionViewCell", bundle: nil),
                    model: todo
                )
                .hasFixedSize(true)
                .handlers { model, view, _ in
                    view.lbTime.text = model?.createdAt.toString()
                    view.lbTitle.text = model?.title
                }
                sizeEstimationHandler: { _, collectionView in
                    CGSize(width: collectionView.frame.width, height: 60)
                }
                didSelectHandler: { [weak self] indexPath in
                    self?.viewModel?.selectTodo(at: indexPath.row)
                }
                CollectionView.Cell()
            }
            if viewModel.isAnimatedLoading {
                CollectionView.LoadingCell(size: CGSize(width: collectionView.frame.width, height: 60))
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
