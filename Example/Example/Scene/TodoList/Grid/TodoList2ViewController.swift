//
//  TodoList2ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreMacros
import CoreRedux
import CoreReduxList
import CoreList
import SwiftDate
import Combine

@SceneView
class TodoList2ViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
#endif
    }
    
#if os(iOS)
    @objc func refreshData(_ sender: UIRefreshControl) {
        Task {
            await self.viewModel?.dispatch(type: .load, payload: 0)
        }
    }
#endif
    
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
                .handlers { model, view, _ in
                    view.lbTime.text = model?.createdAt.toString()
                    view.lbTitle.text = model?.title
                }
                sizeEstimationHandler: { _, collectionView in
                    CGSize(width: collectionView.frame.width, height: 60)
                }
                didSelectHandler: { [weak self] indexPath in
                    Task {
                        await self?.viewModel?.dispatch(type: .selectTodo, payload: indexPath.row)
                    }
                }
            }
            if viewModel.isAnimatedLoading {
                CollectionView.LoadingCell(size: CGSize(width: collectionView.frame.width, height: 60))
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
