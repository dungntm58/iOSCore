//
//  CollectionViewSource.swift
//  CoreList
//
//  Created by Robert on 4/7/20.
//

import UIKit
import DifferenceKit

extension CollectionView {
    enum DI {
        static var generator: [Int: Any] = [:]
        static var cachedCellSize: [String: CGSize] = [:]
        static var cachedHeaderFooterSize: [String: CGSize] = [:]
    }

    open class ViewSourceProvider<Store> {
        public typealias PrototypeSectionBlockGenerateFunction = (UICollectionView, Store) -> CollectionViewSectionBlock
        public typealias PrototypeSectionGenerateFunction = (UICollectionView, Store) -> CollectionViewCellBlock

        private let sectionsGenerator: PrototypeSectionBlockGenerateFunction
        private weak var collectionView: UICollectionView?

        private var viewHashValue: Int {
            didSet {
                DI.generator[viewHashValue] = generator
            }
        }

        private lazy var adapter = createAdapter()
        open var store: Store

        fileprivate var generator: PrototypeGenerator {
            if let generator = DI.generator[viewHashValue] as? PrototypeGenerator {
                return generator
            }
            let generator = PrototypeGenerator(collectionView: collectionView, store: store, generator: sectionsGenerator)
            self.collectionView = nil
            DI.generator[viewHashValue] = generator
            return generator
        }

        deinit {
            DI.generator[viewHashValue] = nil
        }

        public init(collectionView: UICollectionView, store: Store, @SectionBlockBuilder generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self.sectionsGenerator = generator
            self.collectionView = collectionView
            self.viewHashValue = collectionView.hashValue
            self.store = store
            collectionView.delegate = adapter
            collectionView.dataSource = adapter
        }

        public init(collectionView: UICollectionView, store: Store, @CellBlockBuilder generator: @escaping PrototypeSectionGenerateFunction) {
            self.sectionsGenerator = { collectionView, store in
                CollectionView.Section {
                    generator(collectionView, store)
                }
            }
            self.collectionView = collectionView
            self.viewHashValue = collectionView.hashValue
            self.store = store
            collectionView.delegate = adapter
            collectionView.dataSource = adapter
        }

        final public func reload(interrupt: ((Changeset<[AnySection]>) -> Bool)? = nil) {
            let stagedChangeset = StagedChangeset(source: adapter.differenceSections, target: generator.build().sections)
            generator.collectionView?.reload(using: stagedChangeset, interrupt: interrupt) {
                self.adapter.differenceSections = $0
            }
        }

        final public func changeTarget(_ target: UICollectionView) {
            generator.collectionView = target
            viewHashValue = target.hashValue
            target.delegate = adapter
            target.dataSource = adapter
            target.reloadData()
            target.collectionViewLayout.invalidateLayout()
        }

        @inlinable
        open func createAdapter() -> Adapter { .init() }
    }

    @objc(CollectionViewAdapter)
    open class Adapter: NSObject {
        public enum SizeCacheMode {
            case currentContext
            case global
        }

        var differenceSections: [AnySection] = []
        var registeredCellReuseIdentifiers: Set<String> = .init()
        var registeredHeaderFooterReuseIdentifiers: Set<String> = .init()

        var cachedCellSize: [String: CGSize] = [:]
        var cachedHeaderFooterSize: [String: CGSize] = [:]

        open var sizeCacheMode: SizeCacheMode = .currentContext
    }
}

extension CollectionView.Adapter: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        differenceSections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        differenceSections[section].cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = differenceSections[indexPath.section].cells[indexPath.row]
        if !registeredCellReuseIdentifiers.contains(cell.reuseIdentifier) {
            collectionView.register(cell: cell)
            registeredCellReuseIdentifiers.insert(cell.reuseIdentifier)
        }
        let cellView = collectionView.dequeue(cell: cell, for: indexPath)
        cell.bind(model: cell.model, to: cellView, at: indexPath)
        return cellView
    }
}

extension CollectionView.Adapter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = differenceSections[indexPath.section].cells[indexPath.row]
        let cellHashString = cell.hashString
        let size: CGSize
        switch sizeCacheMode {
        case .currentContext:
            if let cachedSize = cachedCellSize[cellHashString] {
                size = cachedSize
            } else {
                size = cell.estimateSize(layout: collectionViewLayout, collectionView: collectionView)
                cachedCellSize[cellHashString] = size
            }
        case .global:
            if let cachedSize = CollectionView.DI.cachedCellSize[cellHashString] {
                size = cachedSize
            } else {
                size = cell.estimateSize(layout: collectionViewLayout, collectionView: collectionView)
                CollectionView.DI.cachedCellSize[cellHashString] = size
            }
        }
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let header = differenceSections[indexPath.section].header {
                return dequeueHeaderFooter(in: collectionView, headerFooter: header, for: indexPath)
            }
        case UICollectionView.elementKindSectionFooter:
            if let footer = differenceSections[indexPath.section].footer {
                return dequeueHeaderFooter(in: collectionView, headerFooter: footer, for: indexPath)
            }            
        default:
            break
        }
        return .init(frame: .zero)
    }

    private func dequeueHeaderFooter(in collectionView: UICollectionView, headerFooter: CollectionView.AnyHeaderFooter, for indexPath: IndexPath) -> UICollectionReusableView {
        if !registeredHeaderFooterReuseIdentifiers.contains(headerFooter.reuseIdentifier) {
            collectionView.register(headerFooter: headerFooter)
            registeredHeaderFooterReuseIdentifiers.insert(headerFooter.reuseIdentifier)
        }
        let headerFooterView = collectionView.dequeue(headerFooter: headerFooter, for: indexPath)
        headerFooter.bind(model: headerFooter.model, to: headerFooterView, at: indexPath)
        return headerFooterView
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].willDisplay(view: cell, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.section < differenceSections.count, indexPath.row < differenceSections[indexPath.section].cells.count else { return }
        differenceSections[indexPath.section].cells[indexPath.row].didEndDisplaying(view: cell, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            differenceSections[indexPath.section].header?.willDisplay(view: view, at: indexPath)
        case UICollectionView.elementKindSectionFooter:
            differenceSections[indexPath.section].footer?.willDisplay(view: view, at: indexPath)
        default:
            break
        }
    }

    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard indexPath.section < differenceSections.count else { return }
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            differenceSections[indexPath.section].header?.didEndDisplaying(view: view, at: indexPath)
        case UICollectionView.elementKindSectionFooter:
            differenceSections[indexPath.section].footer?.didEndDisplaying(view: view, at: indexPath)
        default:
            break
        }
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didSelect(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didDeselect(at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerFooter = differenceSections[section].header else {
            return .zero
        }
        let headerHashString = headerFooter.hashString
        let size: CGSize
        switch sizeCacheMode {
        case .currentContext:
            if let cachedSize = cachedHeaderFooterSize[headerHashString] {
                size = cachedSize
            } else {
                size = headerFooter.estimateSize(layout: collectionViewLayout, collectionView: collectionView)
                cachedHeaderFooterSize[headerHashString] = size
            }
        case .global:
            if let cachedSize = CollectionView.DI.cachedHeaderFooterSize[headerHashString] {
                size = cachedSize
            } else {
                size = headerFooter.estimateSize(layout: collectionViewLayout, collectionView: collectionView)
                CollectionView.DI.cachedHeaderFooterSize[headerHashString] = size
            }
        }
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let headerFooter = differenceSections[section].footer else {
            return .zero
        }
        let headerHashString = headerFooter.hashString
        let size: CGSize
        switch sizeCacheMode {
        case .currentContext:
            if let cachedSize = cachedHeaderFooterSize[headerHashString] {
                size = cachedSize
            } else {
                size = headerFooter.estimateSize(layout: collectionViewLayout, collectionView: collectionView)
                cachedHeaderFooterSize[headerHashString] = size
            }
        case .global:
            if let cachedSize = CollectionView.DI.cachedHeaderFooterSize[headerHashString] {
                size = cachedSize
            } else {
                size = headerFooter.estimateSize(layout: collectionViewLayout, collectionView: collectionView)
                CollectionView.DI.cachedHeaderFooterSize[headerHashString] = size
            }
        }
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        differenceSections[section].inset
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        differenceSections[section].minimumLineSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        differenceSections[section].minimumInteritemSpacing
    }
}

private extension CollectionView.ViewSourceProvider {
    final class PrototypeGenerator {
        var store: Store
        weak var collectionView: UICollectionView?
        let sectionsGenerator: PrototypeSectionBlockGenerateFunction

        init(collectionView: UICollectionView?, store: Store, generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self.collectionView = collectionView
            self.store = store
            self.sectionsGenerator = generator
        }

        @inlinable
        func build() -> CollectionViewSectionBlock {
            guard let collectionView = collectionView else {
                return CollectionView.Section()
            }
            return sectionsGenerator(collectionView, store)
        }
    }
}
