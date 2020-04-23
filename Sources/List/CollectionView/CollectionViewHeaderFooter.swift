//
//  CollectionViewHeaderFooter.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

public protocol CollectionViewHeaderFooter: CellRegisterable, CellBinding, CellPresentable where View: UICollectionReusableView {

    var position: HeaderFooterPosition { get }
    var size: CGSize { get }
}

extension CollectionViewHeaderFooter {
    @inlinable
    public func eraseToAny() -> CollectionView.AnyHeaderFooter { .init(self) }
}

extension CollectionView {
    @frozen
    public struct HeaderFooter<Model, View>: CollectionViewHeaderFooter, CellPresentable where Model: Equatable, View: UICollectionReusableView {
        public let type: CellType
        public let reuseIdentifier: String
        public let position: HeaderFooterPosition
        public var size: CGSize
        public let model: Model?
        @usableFromInline
        var bindingFunction: BindingFunction?
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?

        public init(position: HeaderFooterPosition, type: CellType = .default, reuseIdentifier: String? = nil, model: Model?) {
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.position = position
            self.size = .zero
            self.model = model
        }

        public func size(_ size: CGSize) -> Self {
            var other = self
            other.size = size
            return other
        }

        @inlinable
        public func bind(_ bindingFunction: BindingFunction?) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            return other
        }

        @inlinable
        public func willDisplayHandler(_ willDisplayHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.willDisplayHandler = willDisplayHandler
            return other
        }

        @inlinable
        public func didEndDisplayingHandler(_ didEndDisplayingHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func handlers(bindingFunction: BindingFunction? = nil, willDisplayHandler: IndexPathInteractiveHandler? = nil, didEndDisplayingHandler: IndexPathInteractiveHandler? = nil) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {
            bindingFunction?(model, view, indexPath)
        }

        @inlinable
        public func willDisplay(view: View, at indexPath: IndexPath) {
            willDisplayHandler?(view, indexPath)
        }

        @inlinable
        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            didEndDisplayingHandler?(view, indexPath)
        }
    }
}
