//
//  AppTableView.swift
//  RxCoreList
//
//  Created by Robert on 2/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseTableView: UITableView {
    public typealias DataViewSource = StrictListViewSource & BindableTableViewDataSource

    private lazy var _viewSource: DataViewSource? = _initViewSource()

    public var viewSource: DataViewSource? {
        set {
            _viewSource = newValue
            _viewSource?.register(in: self)
        }
        get { _viewSource }
    }

    private func _initViewSource() -> DataViewSource? {
        let viewSource = initializeViewSource()
        viewSource?.register(in: self)
        return viewSource
    }

    open func initializeViewSource() -> DataViewSource? { nil }
}
