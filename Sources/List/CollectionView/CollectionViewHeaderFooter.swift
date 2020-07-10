//
//  CollectionViewHeaderFooter.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

public protocol CollectionViewHeaderFooter: CellRegisterable, CellBinding, CollectionViewCellPresentable where View: UICollectionReusableView {

    var position: HeaderFooterPosition { get }
}

extension CollectionViewHeaderFooter {
    @inlinable
    public func eraseToAny() -> CollectionView.AnyHeaderFooter { .init(self) }

    @inlinable
    public func estimateSize(in view: View, collectionView: UICollectionView) -> CGSize {
        switch position {
        case .header:
            return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? view.intrinsicContentSize
        case .footer:
            return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? view.intrinsicContentSize
        }
    }
}

extension CollectionView {
    @frozen
    public struct HeaderFooter<Model, View>: CollectionViewHeaderFooter, CellPresentable where Model: Equatable, View: UICollectionReusableView {
        public let type: CellType
        public let reuseIdentifier: String
        public let position: HeaderFooterPosition
        public let model: Model?
        @usableFromInline
        var bindingFunction: BindingFunction?
        @usableFromInline
        var sizeEstimationHandler: SizeEstimationHandler?
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?

        public init(position: HeaderFooterPosition, type: CellType = .default, reuseIdentifier: String? = nil, model: Model?) {
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.position = position
            self.model = model
        }

        @inlinable
        public func bind(_ bindingFunction: BindingFunction?) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            return other
        }

        @inlinable
        public func sizeEstimationHandler(_ sizeEstimationHandler: SizeEstimationHandler?) -> Self {
            var other = self
            other.sizeEstimationHandler = sizeEstimationHandler
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
        public func handlers(bindingFunction: BindingFunction? = nil, sizeEstimationHandler: SizeEstimationHandler? = nil, willDisplayHandler: IndexPathInteractiveHandler? = nil, didEndDisplayingHandler: IndexPathInteractiveHandler? = nil) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.sizeEstimationHandler = sizeEstimationHandler
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {
            bindingFunction?(model, view, indexPath)
        }

        @inlinable
        public func estimateSize(in view: View, collectionView: UICollectionView) -> CGSize {
            if let size = sizeEstimationHandler?(view, collectionView) {
                return size
            }
            switch position {
            case .header:
                return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? view.intrinsicContentSize
            case .footer:
                return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? view.intrinsicContentSize
            }
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
