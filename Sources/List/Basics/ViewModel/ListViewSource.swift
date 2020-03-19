//
//  ListViewSource.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 12/13/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

public struct ListViewSourceModel {
    public static let defaultIdentifier = "defaultIdentifier"

    let type: ListModelChangeType
    let data: [ViewModelItem]
    let needsReload: Bool
    let identifier: String

    public init(type: ListModelChangeType = .initial, data: [ViewModelItem] = [], needsReload: Bool = true, identifier: String = Self.defaultIdentifier) {
        self.type = type
        self.data = data
        self.needsReload = needsReload
        self.identifier = identifier
    }
}

public protocol ListViewSource {
    func models(forIdentifier identifier: String) -> [ViewModelItem]?
    func cell(inSection section: SectionModel, row: Int, onChanged type: ListModelChangeType) -> CellModel
    func section(atSection section: Int, onChanged type: ListModelChangeType) -> SectionModel
    func numberOfDataSections(onChanged type: ListModelChangeType) -> Int
}

public protocol LoadingAnimatableViewSource where Self: ListViewSource {
    var shouldAnimateLoading: Bool { set get }
    var isAnimating: Bool { get }

    func getLoadingCellModel() -> CellModel
}

public typealias StrictListViewSource = ListViewSource & LoadingAnimatableViewSource

public protocol BindableTableViewDataSource {
    func register(in tableView: UITableView)
    func bind(value: ViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath)
    func bindNil(to cell: UITableViewCell, at indexPath: IndexPath)
}

public protocol BindableCollectionViewDataSource {
    func register(in collectionView: UICollectionView)
    func bind(value: ViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath)
    func bindNil(to cell: UICollectionViewCell, at indexPath: IndexPath)
}
