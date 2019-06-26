//
//  ListViewSource.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 12/13/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import DifferenceKit

public struct ListViewSourceModel {
    let type: ListModelChangeType
    let data: [Any]
    let needsReload: Bool
    let identifier: String

    public init(type: ListModelChangeType = .initial, data: [Any] = [], needsReload: Bool = true, identifier: String = "default") {
        self.type = type
        self.data = data
        self.needsReload = needsReload
        self.identifier = identifier
    }
}

public protocol ListViewSource {
    var sections: [SectionModel] { get }
    var cells: [CellModel] { get }

    func models(forIdentifier identifier: String) -> [CleanViewModelItem]?
    func cell(at indexPath: IndexPath) -> CellModel

    func add(sections: [SectionModel])
    func removeSection(at index: Int)
}

public protocol LoadingAnimatableViewSource where Self: ListViewSource {
    var shouldAnimateLoading: Bool { set get }
    var isLoading: Bool { get }

    func getLoadingCellModel() -> CellModel
}

public typealias StrictListViewSource = ListViewSource & LoadingAnimatableViewSource

public protocol BindableTableViewDataSource {
    func register(in tableView: UITableView)
    func bind(value: CleanViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath)
    func bindNil(to cell: UITableViewCell, at indexPath: IndexPath)
}

public protocol BindableCollectionViewDataSource {
    func register(in collectionView: UICollectionView)
    func bind(value: CleanViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath)
    func bindNil(to cell: UICollectionViewCell, at indexPath: IndexPath)
}
