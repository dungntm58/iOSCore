//
//  ListViewSource.swift
//  RxCoreList
//
//  Created by Robert on 4/5/20.
//

import UIKit
import DifferenceKit

extension TableView {
    enum DI {
        static var generator: [Int: Any] = [:]
    }

    open class ViewSourceProvider<Store> {
        public typealias PrototypeSectionBlockGenerateFunction = (UITableView, Store) ->  TableViewSectionBlock
        public typealias PrototypeSectionGenerateFunction = (UITableView, Store) -> TableViewCellBlock
        public typealias RowAnimation = UITableView.RowAnimation

        private var _sectionsGenerator: PrototypeSectionBlockGenerateFunction?
        private var _cellsGenerator: PrototypeSectionGenerateFunction?
        private weak var _tableView: UITableView?

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
                let generator = PrototypeGenerator(tableView: _tableView, store: store, generator: generatorFunction)
                self._tableView = nil
                self._sectionsGenerator = nil
                DI.generator[viewHashValue] = generator
                return generator
            }
            if let generatorFunction = _cellsGenerator {
                let generator = PrototypeGenerator(tableView: _tableView, store: store, generator: generatorFunction)
                self._tableView = nil
                self._cellsGenerator = nil
                DI.generator[viewHashValue] = generator
                return generator
            }
            neverOccur()
        }

        deinit {
            DI.generator[viewHashValue] = nil
        }

        public init(tableView: UITableView, store: Store, @SectionBlockBuilder generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self._sectionsGenerator = generator
            self._tableView = tableView
            self.viewHashValue = tableView.hashValue
            self.store = store
            tableView.delegate = adapter
            tableView.dataSource = adapter
        }

        public init(tableView: UITableView, store: Store, @CellBlockBuilder generator: @escaping PrototypeSectionGenerateFunction) {
            self._cellsGenerator = generator
            self._tableView = tableView
            self.viewHashValue = tableView.hashValue
            self.store = store
            tableView.delegate = adapter
            tableView.dataSource = adapter
        }

        @inlinable
        final public func reload(interrupt: ((Changeset<[AnySection]>) -> Bool)? = nil) {
            reload(animation: .automatic)
        }

        @inlinable
        final public func reload(animation: @autoclosure () -> RowAnimation,
                           interrupt: ((Changeset<[AnySection]>) -> Bool)? = nil
        ) {
            reload(deleteSectionsAnimation: animation(),
                   insertSectionsAnimation: animation(),
                   reloadSectionsAnimation: animation(),
                   deleteRowsAnimation: animation(),
                   insertRowsAnimation: animation(),
                   reloadRowsAnimation: animation())
        }

        final public func reload(deleteSectionsAnimation: @autoclosure () -> RowAnimation,
                    insertSectionsAnimation: @autoclosure () -> RowAnimation,
                    reloadSectionsAnimation: @autoclosure () -> RowAnimation,
                    deleteRowsAnimation: @autoclosure () -> RowAnimation,
                    insertRowsAnimation: @autoclosure () -> RowAnimation,
                    reloadRowsAnimation: @autoclosure () -> RowAnimation,
                    interrupt: ((Changeset<[AnySection]>) -> Bool)? = nil
        ) {
            let stagedChangeset = StagedChangeset(source: adapter.differenceSections, target: generator.build().sections)
            generator.tableView?.reload(using: stagedChangeset,
                              deleteSectionsAnimation: deleteRowsAnimation(),
                              insertSectionsAnimation: insertRowsAnimation(),
                              reloadSectionsAnimation: reloadRowsAnimation(),
                              deleteRowsAnimation: deleteRowsAnimation(),
                              insertRowsAnimation: insertRowsAnimation(),
                              reloadRowsAnimation: reloadRowsAnimation(),
                              interrupt: interrupt) { self.adapter.differenceSections = $0 }
        }

        final public func changeTarget(_ target: UITableView) {
            generator.tableView = target
            viewHashValue = target.hashValue
            target.delegate = adapter
            target.dataSource = adapter
            target.reloadData()
        }

        open func createAdapter() -> Adapter { .init() }
    }

    @objc(TableViewAdapter)
    open class Adapter: NSObject {
        var differenceSections: [AnySection] = []
    }
}

extension TableView.Adapter: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        differenceSections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        differenceSections[section].cells.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = differenceSections[indexPath.section].cells[indexPath.row]
        let cellView: UITableViewCell
        if let _cellView = tableView.dequeue(cell: cell) {
            cellView = _cellView
        } else {
            tableView.register(cell: cell)
            cellView = tableView.dequeue(cell: cell, for: indexPath)
        }
        cell.bind(model: cell.model, to: cellView, at: indexPath)
        return cellView
    }
}

extension TableView.Adapter: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        differenceSections[indexPath.section].cells[indexPath.row].height
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        differenceSections[indexPath.section].cells[indexPath.row].height
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _section = differenceSections[section]
        guard _section.hasHeader, let header = _section.header else { return nil }
        let headerView: UITableViewHeaderFooterView?
        if let _headerView = tableView.dequeue(headerFooter: header) {
            headerView = _headerView
        } else {
            tableView.register(headerFooter: header)
            headerView = tableView.dequeue(headerFooter: header)
        }
        guard let _headerView = headerView else { return nil }
        header.bind(model: header.model, to: _headerView, at: section)
        return _headerView
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let _section = differenceSections[section]
        guard _section.hasFooter, let footer = _section.footer else { return nil }
        let footerView: UITableViewHeaderFooterView?
        if let _footerView = tableView.dequeue(headerFooter: footer) {
            footerView = _footerView
        } else {
            tableView.register(headerFooter: footer)
            footerView = tableView.dequeue(headerFooter: footer)
        }
        guard let _footerView = footerView else { return nil }
        footer.bind(model: footer.model, to: _footerView, at: section)
        return _footerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = differenceSections[section]
        guard section.hasHeader else {
            return tableView.leastOfHeaderFooterHeight
        }
        return section.header?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let section = differenceSections[section]
        guard section.hasHeader else {
            return tableView.leastOfHeaderFooterHeight
        }
        return section.header?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = differenceSections[section]
        guard section.hasFooter else {
            return tableView.leastOfHeaderFooterHeight
        }
        return section.footer?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let section = differenceSections[section]
        guard section.hasFooter else {
            return tableView.leastOfHeaderFooterHeight
        }
        return section.footer?.height ?? tableView.leastOfHeaderFooterHeight
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].willDisplay(view: cell, at: indexPath)
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didEndDisplaying(view: cell, at: indexPath)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        differenceSections[section].header?.willDisplay(view: view as! UITableViewHeaderFooterView, at: section)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        differenceSections[section].header?.didEndDisplaying(view: view as! UITableViewHeaderFooterView, at: section)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        differenceSections[section].footer?.willDisplay(view: view as! UITableViewHeaderFooterView, at: section)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        differenceSections[section].footer?.didEndDisplaying(view: view as! UITableViewHeaderFooterView, at: section)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didSelect(at: indexPath)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didDeselect(at: indexPath)
    }
}

private extension TableView.ViewSourceProvider {
    final class PrototypeGenerator {
        var store: Store
        weak var tableView: UITableView?
        var sectionsGenerator: PrototypeSectionBlockGenerateFunction?
        var cellsGenerator: PrototypeSectionGenerateFunction?

        deinit {
            sectionsGenerator = nil
            cellsGenerator = nil
        }

        init(tableView: UITableView?, store: Store, generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self.store = store
            self.tableView = tableView
            self.sectionsGenerator = generator
            self.cellsGenerator = nil
        }

        init(tableView: UITableView?, store: Store, generator: @escaping PrototypeSectionGenerateFunction) {
            self.store = store
            self.tableView = tableView
            self.sectionsGenerator = nil
            self.cellsGenerator = generator
        }

        func build() -> TableViewSectionBlock {
            guard let tableView = tableView else {
                return TableView.Section()
            }
            if let generator = sectionsGenerator {
                return generator(tableView, store)
            }
            if let generator = cellsGenerator {
                return TableView.Section() {
                    generator(tableView, store)
                }
            }
            return TableView.Section()
        }
    }
}
