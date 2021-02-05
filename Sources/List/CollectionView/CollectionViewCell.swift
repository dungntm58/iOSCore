//
//  CollectionViewCell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

public protocol CollectionViewCellPresentable: CellPresentable {
    typealias SizeEstimationHandler = (View, UICollectionView) -> CGSize

    func estimateSize(in view: View, collectionView: UICollectionView) -> CGSize
    var hasFixedSize: Bool { get }
}

public protocol CollectionViewCell: CellRegisterable, CellBinding, CollectionViewCellPresentable, Identifiable where View: UICollectionViewCell, Model: Equatable {
}

extension CollectionViewCell {
    @inlinable
    public func eraseToAny() -> CollectionView.AnyCell { .init(self) }

    @inlinable
    public func estimateSize(in view: View, collectionView: UICollectionView) -> CGSize {
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? view.intrinsicContentSize
    }
}

extension CollectionView {
    @frozen
    public struct Cell<ID, Model, View>: CollectionViewCell, CollectionViewCellBlock, CellInteractable where ID: Hashable, Model: Equatable, View: UICollectionViewCell {
        public var id: ID
        public let type: CellType
        public let reuseIdentifier: String
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
        @usableFromInline
        var didSelectHandler: SelectionInteractiveHandler?
        @usableFromInline
        var didDeselectHandler: SelectionInteractiveHandler?

        public init(id: ID, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.model = model
            self.hasFixedSize = true
        }

        public init(id: ID, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            let type: CellType
            if View.self === UICollectionViewCell.self {
                type = .default
            } else {
                type = .nib(nibName: String(describing: View.self), bundle: Bundle(for: View.classForCoder()))
            }
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.model = model
            self.hasFixedSize = true
        }

        public func hasFixedSize(_ hasFixedSize: Bool) -> Self {
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
        public func didSelectHandler(_ didSelectHandler: SelectionInteractiveHandler?) -> Self {
            var other = self
            other.didSelectHandler = didSelectHandler
            return other
        }

        @inlinable
        public func didDeselectHandler(_ didDeselectHandler: SelectionInteractiveHandler?) -> Self {
            var other = self
            other.didDeselectHandler = didDeselectHandler
            return other
        }

        @inlinable
        public func handlers(bindingFunction: BindingFunction? = nil, sizeEstimationHandler: SizeEstimationHandler? = nil, willDisplayHandler: IndexPathInteractiveHandler? = nil, didEndDisplayingHandler: IndexPathInteractiveHandler? = nil, didSelectHandler: SelectionInteractiveHandler? = nil, didDeselectHandler: SelectionInteractiveHandler? = nil) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.sizeEstimationHandler = sizeEstimationHandler
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            other.didSelectHandler = didSelectHandler
            other.didDeselectHandler = didDeselectHandler
            return other
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {
            bindingFunction?(model, view, indexPath)
        }

        @inlinable
        public func estimateSize(in view: View, collectionView: UICollectionView) -> CGSize {
            sizeEstimationHandler?(view, collectionView) ?? (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? view.intrinsicContentSize
        }

        @inlinable
        public func willDisplay(view: View, at indexPath: IndexPath) {
            willDisplayHandler?(view, indexPath)
        }

        @inlinable
        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            didEndDisplayingHandler?(view, indexPath)
        }

        @inlinable
        public func didSelect(at indexPath: IndexPath) {
            didSelectHandler?(indexPath)
        }

        @inlinable
        public func didDeselect(at indexPath: IndexPath) {
            didDeselectHandler?(indexPath)
        }
    }

    @frozen
    public struct LoadingCell: CollectionViewCell, CollectionViewCellBlock, CellPresentable {
        public typealias Model = AnyEquatable
        public typealias View = LoadingCollectionViewCell

        public let id: LoadingIdentifier
        public let type: CellType
        public let reuseIdentifier: String
        public let size: CGSize
        public let model: Model?
        public let hasFixedSize: Bool
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?

        public init(size: CGSize) {
            self.id = .init()
            self.type = .nib(nibName: "LoadingCollectionViewCell", bundle: Bundle(for: LoadingCollectionViewCell.classForCoder()))
            self.reuseIdentifier = type.identifier
            self.size = size
            self.model = nil
            self.hasFixedSize = true
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {}

        @inlinable
        public func estimateSize(in view: LoadingCollectionViewCell, collectionView: UICollectionView) -> CGSize {
            size
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
        public func willDisplay(view: View, at indexPath: IndexPath) {
            willDisplayHandler?(view, indexPath)
        }

        @inlinable
        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            didEndDisplayingHandler?(view, indexPath)
        }
    }
}

extension CollectionView.Cell where ID == UniqueIdentifier {
    @inlinable
    public init(type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), type: type, reuseIdentifier: reuseIdentifier, model: model)
    }

    @inlinable
    public init(reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), reuseIdentifier: reuseIdentifier, model: model)
    }
}

public protocol CollectionViewCellBlock {
    @inlinable
    var cells: [CollectionView.AnyCell] { get }
}

extension CollectionViewCellBlock where Self: CollectionViewCell {
    @inlinable
    public var cells: [CollectionView.AnyCell] { [eraseToAny()] }
}

extension Optional: CollectionViewCellBlock where Wrapped: CollectionViewCell {
    @inlinable
    public var cells: [CollectionView.AnyCell] {
        switch self {
        case .none:
            return []
        case .some(let section):
            return [section.eraseToAny()]
        }
    }
}

extension Array: CollectionViewCellBlock where Element: CollectionViewCellBlock {
    @inlinable
    public var cells: [CollectionView.AnyCell] { flatMap { $0.cells } }
}

extension ForEach: CollectionViewCellBlock where Content == CollectionViewCellBlock {
    @inlinable
    public var cells: [CollectionView.AnyCell] { elements.flatMap { $0.cells } }

    @inlinable
    public init(_ data: Data, @CollectionView.CellBlockBuilder content: (Int, Data.Element) -> CollectionViewCellBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
