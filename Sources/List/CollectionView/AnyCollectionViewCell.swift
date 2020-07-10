//
//  AnyCollectionViewCell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

extension CollectionView {
    public struct AnyCell: CollectionViewCell, CollectionViewCellBlock, CellInteractable {
        public typealias ID = AnyHashable
        public typealias Model = AnyEquatable
        public typealias View = UICollectionViewCell

        private let box: AnyCollectionViewCellBox

        @usableFromInline
        init<Cell>(_ cell: Cell) where Cell: CollectionViewCell {
            if let _cell = cell as? AnyCell {
                self = _cell
            } else {
                box = CellBox(cell)
            }
        }

        public var id: ID { box.id }
        public var type: CellType { box.type }
        public var reuseIdentifier: String { box.reuseIdentifier }
        public var model: Model? { box.model }
        var hashString: String { box.hashString }

        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {
            box.bind(model: model?.base, to: view, at: indexPath)
        }

        public func estimateSize(in view: UICollectionViewCell, collectionView: UICollectionView) -> CGSize {
            box.estimateSize(in: view, collectionView: collectionView)
        }

        public func willDisplay(view: View, at indexPath: IndexPath) {
            box.willDisplay(view: view, at: indexPath)
        }

        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            box.didEndDisplaying(view: view, at: indexPath)
        }

        public func didSelect(at indexPath: IndexPath) {
            box.didSelect(at: indexPath)
        }

        public func didDeselect(at indexPath: IndexPath) {
            box.didDeselect(at: indexPath)
        }
    }
}

private protocol AnyCollectionViewCellBox: CellInteractable {
    var id: AnyHashable { get }
    var type: CellType { get }
    var reuseIdentifier: String { get }
    var model: AnyEquatable? { get }
    var hashString: String { get }

    func bind(model: Any?, to view: UICollectionViewCell, at indexPath: IndexPath)
    func estimateSize(in view: UICollectionViewCell, collectionView: UICollectionView) -> CGSize
    func willDisplay(view: UICollectionViewCell, at indexPath: IndexPath)
    func didEndDisplaying(view: UICollectionViewCell, at indexPath: IndexPath)
}

private extension CollectionView.AnyCell {
    struct CellBox<Base>: AnyCollectionViewCellBox where Base: CollectionViewCell {
        @usableFromInline
        let _base: Base
        @usableFromInline
        let hashString: String

        @inlinable
        init(_ base: Base) {
            self._base = base
            self.hashString = String(describing: Base.View.self) + String(describing: base.model)
        }

        @inlinable
        var id: AnyHashable { _base.id }

        @inlinable
        var type: CellType { _base.type }

        @inlinable
        var reuseIdentifier: String { _base.reuseIdentifier }

        @inlinable
        var model: AnyEquatable? { _base.model?.eraseToAny() }

        @inlinable
        func bind(model: Any?, to view: UICollectionViewCell, at indexPath: IndexPath) {
            guard let view = view as? Base.View else {
                preconditionFailure("Opaque cell must associate with view type \(String(describing: Base.Model.self))")
            }
            _base.bind(model: model as? Base.Model, to: view, at: indexPath)
        }

        @inlinable
        func estimateSize(in view: UICollectionViewCell, collectionView: UICollectionView) -> CGSize {
            guard let view = view as? Base.View else { return .zero }
            return _base.estimateSize(in: view, collectionView: collectionView)
        }

        @inlinable
        func willDisplay(view: UICollectionViewCell, at indexPath: IndexPath) {
            guard let view = view as? Base.View else { return }
            _base.willDisplay(view: view, at: indexPath)
        }

        @inlinable
        func didEndDisplaying(view: UICollectionViewCell, at indexPath: IndexPath) {
            guard let view = view as? Base.View else { return }
            _base.didEndDisplaying(view: view, at: indexPath)
        }

        @inlinable
        func didSelect(at indexPath: IndexPath) {
            (_base as? CellInteractable)?.didSelect(at: indexPath)
        }

        @inlinable
        func didDeselect(at indexPath: IndexPath) {
            (_base as? CellInteractable)?.didDeselect(at: indexPath)
        }
    }
}
