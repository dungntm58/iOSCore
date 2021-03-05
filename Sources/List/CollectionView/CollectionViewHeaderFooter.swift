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
    public func estimateSize(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize {
        switch position {
        case .header:
            return (layout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        case .footer:
            return (layout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
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
        internal(set) public var hasFixedSize: Bool
        @usableFromInline
        var bindingFunction: BindingFunction?
        @usableFromInline
        var sizeEstimationHandler: SizeEstimationHandler?
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?
        
        public init(position: HeaderFooterPosition, reuseIdentifier: String? = nil, model: Model? = nil) {
            let type: CellType
            if View.self === UICollectionReusableView.self {
                preconditionFailure("View must be a subclass of UICollectionReusableView")
            } else {
                type = .nib(nibName: String(describing: View.self), bundle: Bundle(for: View.classForCoder()))
            }
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.position = position
            self.model = model
            self.hasFixedSize = true
        }

        public init(position: HeaderFooterPosition, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
            if case .default = type {
                assertionFailure("Type default is not supported")
            }
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.position = position
            self.model = model
            self.hasFixedSize = true
        }

        public func hasSizeFixed(_ hasSizeFixed: Bool) -> Self {
            var other = self
            other.hasFixedSize = hasFixedSize
            return other
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
        public func estimateSize(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize {
            if let size = sizeEstimationHandler?(layout, collectionView) {
                return size
            }
            switch position {
            case .header:
                return (layout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
            case .footer:
                return (layout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
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

extension CollectionView.HeaderFooter where Model == AnyEquatable {
    @inlinable
    public init(position: HeaderFooterPosition, reuseIdentifier: String? = nil) {
        self.init(position: position, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(position: HeaderFooterPosition, type: CellType, reuseIdentifier: String? = nil) {
        self.init(position: position, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }
}
