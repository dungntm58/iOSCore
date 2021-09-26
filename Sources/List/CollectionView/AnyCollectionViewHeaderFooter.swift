//
//  AnyCollectionViewHeaderFooter.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation
import UIKit

extension CollectionView {
    public struct AnyHeaderFooter: CollectionViewHeaderFooter, CellPresentable {
        public typealias View = UICollectionReusableView

        private let box: AnyCollectionViewHeaderFooterBox

        @usableFromInline
        init<Cell>(_ cell: Cell) where Cell: CollectionViewHeaderFooter {
            if let instance = cell as? AnyHeaderFooter {
                self = instance
            } else {
                box = HeaderFooterBox(cell)
            }
        }

        public var type: CellType { box.type }
        public var reuseIdentifier: String { box.reuseIdentifier }
        public var position: HeaderFooterPosition { box.position }
        public var model: Any? { box.model }
        public var hasFixedSize: Bool { box.hasFixedSize }
        public var estimatedSize: CGSize? { box.estimatedSize }
        var hashString: String { box.hashString }

        public func bind(to view: View, at indexPath: IndexPath) {
            box.bind(to: view, at: indexPath)
        }

        public func size(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize {
            box.size(layout: layout, collectionView: collectionView)
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
    }
}

private protocol AnyCollectionViewHeaderFooterBox {
    var type: CellType { get }
    var reuseIdentifier: String { get }
    var position: HeaderFooterPosition { get }
    var model: Any? { get }
    var hasFixedSize: Bool { get }
    var hashString: String { get }
    var estimatedSize: CGSize? { get }

    func bind(to view: UICollectionReusableView, at indexPath: IndexPath)
    func size(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize
    func willDisplay(view: UICollectionReusableView, at indexPath: IndexPath)
    func didEndDisplaying(view: UICollectionReusableView, at indexPath: IndexPath)
}

private extension CollectionView.AnyHeaderFooter {
    struct HeaderFooterBox<Base>: AnyCollectionViewHeaderFooterBox where Base: CollectionViewHeaderFooter {
        @usableFromInline
        let _base: Base
        @usableFromInline
        let hashString: String

        @inlinable
        init(_ base: Base) {
            self._base = base
            let viewHash: String
            switch base.type {
            case .default:
                viewHash = "UICollectionReusableView"
            case .class(let `class`):
                viewHash = "\(String(describing: `class`))_\(Bundle(for: `class`).bundleIdentifier ?? "")"
            case .nib(let nibName, let bundle):
                if let bundleID = bundle?.bundleIdentifier {
                    viewHash = "\(nibName)_\(bundleID)"
                } else {
                    viewHash = nibName
                }
            }
            if self._base.hasFixedSize {
                self.hashString = viewHash
            } else {
                self.hashString = viewHash + String(describing: base.model)
            }
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
        var model: Any? { _base.model }

        @inlinable
        var hasFixedSize: Bool { _base.hasFixedSize }

        @inlinable
        var estimatedSize: CGSize? { _base.estimatedSize }

        @inlinable
        func bind(to view: UICollectionReusableView, at indexPath: IndexPath) {
            guard let view = view as? Base.View else {
                assertionFailure("Opaque cell must associate with view type \(String(describing: Base.View.self))")
                return
            }
            _base.bind(to: view, at: indexPath)
        }

        @inlinable
        func size(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize {
            _base.size(layout: layout, collectionView: collectionView)
        }

        @inlinable
        func willDisplay(view: UICollectionReusableView, at indexPath: IndexPath) {
            guard let view = view as? Base.View else { return }
            _base.willDisplay(view: view, at: indexPath)
        }

        @inlinable
        func didEndDisplaying(view: UICollectionReusableView, at indexPath: IndexPath) {
            guard let view = view as? Base.View else { return }
            _base.didEndDisplaying(view: view, at: indexPath)
        }
    }
}
