//
//  AnyCollectionViewHeaderFooter.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

extension CollectionView {
    public struct AnyHeaderFooter: CollectionViewHeaderFooter, CellPresentable {
        public typealias View = UICollectionReusableView

        private let box: AnyCollectionViewHeaderFooterBox

        @usableFromInline
        init<Cell>(_ cell: Cell) where Cell: CollectionViewHeaderFooter  {
            if let _cell = cell as? AnyHeaderFooter {
                self = _cell
            } else {
                box = HeaderFooterBox(cell)
            }
        }

        public var type: CellType { box.type }
        public var reuseIdentifier: String { box.reuseIdentifier }
        public var position: HeaderFooterPosition { box.position }
        public var size: CGSize { box.size }
        public var model: Any? { box.model }

        public func bind(model: Any?, to view: View, at indexPath: IndexPath) {
            box.bind(model: model, to: view, at: indexPath)
        }

        public func willDisplay(view: View, at indexPath: IndexPath) {
            box.willDisplay(view: view, at: indexPath)
        }

        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            box.didEndDisplaying(view: view, at: indexPath)
        }

        @inlinable
        public static var none: AnyHeaderFooter? { nil }
    }
}

extension CollectionView.AnyHeaderFooter: Equatable {
    @inlinable
    public static func == (lhs: CollectionView.AnyHeaderFooter, rhs: CollectionView.AnyHeaderFooter) -> Bool {
        lhs.reuseIdentifier == rhs.reuseIdentifier
            && lhs.size == rhs.size
    }
}

private protocol AnyCollectionViewHeaderFooterBox {
    var type: CellType { get }
    var reuseIdentifier: String { get }
    var position: HeaderFooterPosition { get }
    var size: CGSize { get }
    var model: Any? { get }

    func bind(model: Any?, to view: UICollectionReusableView, at indexPath: IndexPath)
    func willDisplay(view: UICollectionReusableView, at indexPath: IndexPath)
    func didEndDisplaying(view: UICollectionReusableView, at indexPath: IndexPath)
}

private extension CollectionView.AnyHeaderFooter {
    struct HeaderFooterBox<Base>: AnyCollectionViewHeaderFooterBox where Base: CollectionViewHeaderFooter {
        @usableFromInline
        let _base: Base

        @inlinable
        init(_ base: Base) {
            self._base = base
        }

        @inlinable
        var base: Any { _base }

        @inlinable
        var type: CellType { _base.type }

        @inlinable
        var reuseIdentifier: String { _base.reuseIdentifier }

        @inlinable
        var position: HeaderFooterPosition { _base.position }

        @inlinable
        var size: CGSize { _base.size }

        @inlinable
        var model: Any? { _base.model }

        @inlinable
        func bind(model: Any?, to view: UICollectionReusableView, at indexPath: IndexPath) {
            guard let view = view as? Base.View else {
                preconditionFailure("Opaque cell must associate with view type \(String(describing: Base.Model.self))")
            }
            _base.bind(model: model as? Base.Model, to: view, at: indexPath)
        }

        @inlinable
        func willDisplay(view: UICollectionReusableView, at indexPath: IndexPath) {
            _base.willDisplay(view: view as! Base.View, at: indexPath)
        }

        @inlinable
        func didEndDisplaying(view: UICollectionReusableView, at indexPath: IndexPath) {
            _base.didEndDisplaying(view: view as! Base.View, at: indexPath)
        }
    }
}
