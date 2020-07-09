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
    }

    open class ViewSourceProvider<Store> {
        public typealias PrototypeSectionBlockGenerateFunction = (UICollectionView, Store) -> CollectionViewSectionBlock
        public typealias PrototypeSectionGenerateFunction = (UICollectionView, Store) -> CollectionViewCellBlock

        private var _sectionsGenerator: PrototypeSectionBlockGenerateFunction?
        private var _cellsGenerator: PrototypeSectionGenerateFunction?
        private weak var _collectionView: UICollectionView?

        private var viewHashValue: Int {
            willSet {
                DI.generator[viewHashValue] = nil
                DI.generator[newValue] = generator
            }
        }

        private lazy var adapter = createAdapter()
        open var store: Store

        fileprivate var generator: PrototypeGenerator {
            if let generator = DI.generator[viewHashValue] as? PrototypeGenerator {
                return generator
            }
            if let generatorFunction = _sectionsGenerator {
                let generator = PrototypeGenerator(collectionView: _collectionView, store: store, generator: generatorFunction)
                self._collectionView = nil
                self._sectionsGenerator = nil
                DI.generator[viewHashValue] = generator
                return generator
            }
            if let generatorFunction = _cellsGenerator {
                let generator = PrototypeGenerator(collectionView: _collectionView, store: store, generator: generatorFunction)
                self._collectionView = nil
                self._cellsGenerator = nil
                DI.generator[viewHashValue] = generator
                return generator
            }
            neverOccur()
        }

        deinit {
            DI.generator[viewHashValue] = nil
        }

        public init(collectionView: UICollectionView, store: Store, @SectionBlockBuilder generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self._sectionsGenerator = generator
            self._collectionView = collectionView
            self.viewHashValue = collectionView.hashValue
            self.store = store
            collectionView.delegate = adapter
            collectionView.dataSource = adapter
        }

        public init(collectionView: UICollectionView, store: Store, @CellBlockBuilder generator: @escaping PrototypeSectionGenerateFunction) {
            self._cellsGenerator = generator
            self._collectionView = collectionView
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
        var differenceSections: [AnySection] = []
        var registeredCellReuseIdentifiers: Set<String> = .init()
        var registeredHeaderFooterReuseIdentifiers: Set<String> = .init()
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
        differenceSections[indexPath.section].cells[indexPath.row].size
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = differenceSections[indexPath.section].header else {
                return .init(frame: .zero)
            }
            if !registeredHeaderFooterReuseIdentifiers.contains(header.reuseIdentifier) {
                collectionView.register(headerFooter: header)
                registeredHeaderFooterReuseIdentifiers.insert(header.reuseIdentifier)
            }
            let headerView = collectionView.dequeue(headerFooter: header, for: indexPath)
            header.bind(model: header.model, to: headerView, at: indexPath)
            return headerView
        case UICollectionView.elementKindSectionFooter:
            guard let footer = differenceSections[indexPath.section].footer else {
                return .init(frame: .zero)
            }
            if !registeredHeaderFooterReuseIdentifiers.contains(footer.reuseIdentifier) {
                collectionView.register(headerFooter: footer)
                registeredHeaderFooterReuseIdentifiers.insert(footer.reuseIdentifier)
            }
            let footerView = collectionView.dequeue(headerFooter: footer, for: indexPath)
            footer.bind(model: footer.model, to: footerView, at: indexPath)
            return footerView
        default:
            neverOccur()
        }
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
        differenceSections[section].header?.size ?? .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        differenceSections[section].footer?.size ?? .zero
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
        var sectionsGenerator: PrototypeSectionBlockGenerateFunction?
        var cellsGenerator: PrototypeSectionGenerateFunction?

        deinit {
            sectionsGenerator = nil
            cellsGenerator = nil
        }

        init(collectionView: UICollectionView?, store: Store, generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self.collectionView = collectionView
            self.store = store
            self.sectionsGenerator = generator
            self.cellsGenerator = nil
        }

        init(collectionView: UICollectionView?, store: Store, generator: @escaping PrototypeSectionGenerateFunction) {
            self.collectionView = collectionView
            self.store = store
            self.sectionsGenerator = nil
            self.cellsGenerator = generator
        }

        @inlinable
        func build() -> CollectionViewSectionBlock {
            guard let collectionView = collectionView else {
                return CollectionView.Section()
            }
            if let generator = sectionsGenerator {
                return generator(collectionView, store)
            }
            if let generator = cellsGenerator {
                return CollectionView.Section() {
                    generator(collectionView, store)
                }
            }
            return CollectionView.Section()
        }
    }
}
