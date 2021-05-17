//
//  CollectionViewCell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import FoundationExt_R

public protocol CollectionViewSectionComponent {
    func asCells() -> [CollectionView.AnyCell]
    func asHeaderFooter() -> (CollectionView.AnyHeaderFooter?, CollectionView.AnyHeaderFooter?)
}

public protocol CollectionViewCellPresentable: CellPresentable {
    typealias SizeEstimationHandler = (UICollectionViewLayout, UICollectionView) -> CGSize

    var estimatedSize: CGSize? { get }
    func size(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize
    var hasFixedSize: Bool { get }
}

public protocol CollectionViewCell: CollectionViewSectionComponent, CellRegisterable, CellBinding, CollectionViewCellPresentable, Identifiable where View: UICollectionViewCell, Model: Equatable {
}

extension CollectionViewCell {
    @inlinable
    public func asCells() -> [CollectionView.AnyCell] { [eraseToAny()] }

    @inlinable
    public func asHeaderFooter() -> (CollectionView.AnyHeaderFooter?, CollectionView.AnyHeaderFooter?) {
        (nil, nil)
    }

    @inlinable
    public func eraseToAny() -> CollectionView.AnyCell { .init(self) }

    @inlinable
    public func size(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize {
        estimatedSize ?? (layout as? UICollectionViewFlowLayout)?.itemSize ?? .init(width: 50, height: 50)
    }
}

extension CollectionView {
    @frozen
    public struct Cell<ID, Model, View>: CollectionViewCell, CollectionViewSectionComponent, CellInteractable where ID: Hashable, Model: Equatable, View: UICollectionViewCell {
        public var id: ID
        public let type: CellType
        public let reuseIdentifier: String
        public let model: Model?
        internal(set) public var estimatedSize: CGSize?
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

        public init(id: ID, cellType: View.Type, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.model = model
            self.hasFixedSize = true
        }

        public init(id: ID, cellType: View.Type, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            let type: CellType
            if cellType === UICollectionViewCell.self {
                type = .default
            } else {
                type = .nib(nibName: String(describing: cellType), bundle: Bundle(for: View.classForCoder()))
            }
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

        public func estimatedSize(_ size: CGSize?) -> Self {
            var other = self
            other.estimatedSize = size
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
        public func handlers(
            bindingFunction: BindingFunction? = nil,
            sizeEstimationHandler: SizeEstimationHandler? = nil,
            willDisplayHandler: IndexPathInteractiveHandler? = nil,
            didEndDisplayingHandler: IndexPathInteractiveHandler? = nil,
            didSelectHandler: SelectionInteractiveHandler? = nil,
            didDeselectHandler: SelectionInteractiveHandler? = nil
        ) -> Self {
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
        public func size(layout: UICollectionViewLayout, collectionView: UICollectionView) -> CGSize {
            estimatedSize ?? sizeEstimationHandler?(layout, collectionView) ?? (layout as? UICollectionViewFlowLayout)?.itemSize ?? CGSize(width: 50, height: 50)
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
    public struct LoadingCell: CollectionViewCell, CellPresentable {
        public typealias Model = AnyEquatable
        public typealias View = LoadingCollectionViewCell

        public let id: LoadingIdentifier
        public let type: CellType
        public let reuseIdentifier: String
        public let estimatedSize: CGSize?
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
            self.estimatedSize = size
            self.model = nil
            self.hasFixedSize = true
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {}

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
    public init(cellType: View.Type, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), cellType: cellType, type: type, reuseIdentifier: reuseIdentifier, model: model)
    }

    @inlinable
    public init(cellType: View.Type, reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), cellType: cellType, reuseIdentifier: reuseIdentifier, model: model)
    }

    @inlinable
    public init(reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), reuseIdentifier: reuseIdentifier, model: model)
    }
}

extension CollectionView.Cell where Model == AnyEquatable {
    @inlinable
    public init(id: ID, type: CellType, reuseIdentifier: String? = nil) {
        self.init(id: id, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(id: ID, cellType: View.Type, reuseIdentifier: String? = nil) {
        self.init(id: id, cellType: cellType, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(id: ID, cellType: View.Type, type: CellType, reuseIdentifier: String? = nil) {
        self.init(id: id, cellType: cellType, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(id: ID, reuseIdentifier: String? = nil) {
        self.init(id: id, reuseIdentifier: reuseIdentifier, model: nil)
    }
}

extension CollectionView.Cell where ID == UniqueIdentifier, Model == AnyEquatable {
    @inlinable
    public init(type: CellType, reuseIdentifier: String? = nil) {
        self.init(type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(cellType: View.Type, reuseIdentifier: String? = nil) {
        self.init(cellType: cellType, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(cellType: View.Type, type: CellType, reuseIdentifier: String? = nil) {
        self.init(cellType: cellType, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(reuseIdentifier: String? = nil) {
        self.init(reuseIdentifier: reuseIdentifier, model: nil)
    }
}

extension Array: CollectionViewSectionComponent where Element: CollectionViewCell {
    @inlinable
    public func asCells() -> [CollectionView.AnyCell] { map { $0.eraseToAny() } }

    @inlinable
    public func asHeaderFooter() -> (CollectionView.AnyHeaderFooter?, CollectionView.AnyHeaderFooter?) { (nil, nil) }
}

@available(*, deprecated)
extension ForEach: CollectionViewSectionComponent where Content == CollectionViewSectionComponent {
    @inlinable
    public func asCells() -> [CollectionView.AnyCell] { elements.flatMap { $0.asCells() } }

    @inlinable
    public func asHeaderFooter() -> (CollectionView.AnyHeaderFooter?, CollectionView.AnyHeaderFooter?) { (nil, nil) }

    @inlinable
    public init(_ data: Data, @CollectionView.SectionBuilder content: (Int, Data.Element) -> CollectionViewSectionComponent) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
