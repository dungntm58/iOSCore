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
import Combine

class TodoList2ViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refreshControl = UIRefreshControl()
    
    lazy var cancellables = Set<AnyCancellable>()
    
    @SceneDependencyReferenced var viewModel: TodoStore?
    
    lazy var viewSourceProvider = createViewSourceProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }
        
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
                    self.refreshControl.endRefreshing()
                }
                self.viewSourceProvider.reload()
            })
            .store(in: &cancellables)
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.viewModel?.dispatch(type: .load, payload: 0)
    }
    
    func createViewSourceProvider() -> CollectionView.ViewSourceProvider<TodoViewModel> {
        return .init(collectionView: collectionView, store: .init()) {
            collectionView, viewModel in
            ForEach(viewModel.todos) {
                index, todo in
                CollectionView.Cell(
                    id: index,
                    cellType: TodoCollectionViewCell.self,
                    model: todo
                )
                .handlers { model, view, _ in
                    view.lbTime.text = model?.createdAt.toString()
                    view.lbTitle.text = model?.title
                }
                sizeEstimationHandler: { _, collectionView in
                    CGSize(width: collectionView.frame.width, height: 60)
                }
                didSelectHandler: { [weak self] indexPath in
                    self?.viewModel?.dispatch(type: .selectTodo, payload: indexPath.row)
                }
            }
            if viewModel.isAnimatedLoading {
                CollectionView.LoadingCell(size: CGSize(width: collectionView.frame.width, height: 60))
                    .willDisplayHandler { [weak self] view, indexPath in
                        guard let self = self else { return }
                        viewModel.isAnimatedLoading ? view.startAnimation() : view.stopAnimation()
                        
                        let currentPage = self.viewModel?.currentState.list.currentPage ?? 0
                        self.viewModel?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
                    }
            }
        }
    }
}
