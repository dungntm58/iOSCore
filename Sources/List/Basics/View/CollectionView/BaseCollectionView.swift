//
//  AppCollectionView.swift
//  RxCoreList
//
//  Created by Robert on 3/27/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseCollectionView: UICollectionView {
    public typealias DataViewSource = StrictListViewSource & BindableCollectionViewDataSource

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
