//
//  ListViewSource.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import UIKit
import DifferenceKit

extension TableView {
    enum DIC {
        static var generator: [Int: Any] = [:]
    }

    open class ViewSourceProvider<Store> {
        public typealias PrototypeSectionBlockGenerateFunction = (UITableView, Store) -> TableViewSectionBlock
        public typealias PrototypeSectionGenerateFunction = (UITableView, Store) -> TableViewSectionComponent
        public typealias RowAnimation = UITableView.RowAnimation

        private var sectionsGenerator: PrototypeSectionBlockGenerateFunction
        private weak var tableView: UITableView?

        private var viewHashValue: Int {
            didSet {
                DIC.generator[viewHashValue] = generator
            }
        }

        private lazy var adapter = createAdapter()
        open var store: Store

        fileprivate var generator: PrototypeGenerator {
            if let generator = DIC.generator[viewHashValue] as? PrototypeGenerator {
                return generator
            }
            let generator = PrototypeGenerator(tableView: tableView, store: store, generator: sectionsGenerator)
            self.tableView = nil
            DIC.generator[viewHashValue] = generator
            return generator
        }

        deinit {
            DIC.generator[viewHashValue] = nil
        }

        public init(tableView: UITableView, store: Store, @SectionBlockBuilder generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self.sectionsGenerator = generator
            self.tableView = tableView
            self.viewHashValue = tableView.hashValue
            self.store = store
            tableView.delegate = adapter
            tableView.dataSource = adapter
        }

        public init(tableView: UITableView, store: Store, @SectionBuilder generator: @escaping PrototypeSectionGenerateFunction) {
            self.sectionsGenerator = { tableView, store in
                let section = TableView.Section(component: generator(tableView, store))
                return [section]
            }
            self.tableView = tableView
            self.viewHashValue = tableView.hashValue
            self.store = store
            tableView.delegate = adapter
            tableView.dataSource = adapter
        }

        @inlinable
        final public func reload(interrupt: ((Changeset<[AnySection]>) -> Bool)? = nil) {
            reload(animation: .automatic, interrupt: interrupt)
        }

        @inlinable
        final public func reload(
            animation: @autoclosure () -> RowAnimation,
            interrupt: ((Changeset<[AnySection]>) -> Bool)? = nil
        ) {
            reload(deleteSectionsAnimation: animation(),
                   insertSectionsAnimation: animation(),
                   reloadSectionsAnimation: animation(),
                   deleteRowsAnimation: animation(),
                   insertRowsAnimation: animation(),
                   reloadRowsAnimation: animation(),
                   interrupt: interrupt)
        }

        // swiftlint:disable function_parameter_count
        final public func reload(
            deleteSectionsAnimation: @autoclosure () -> RowAnimation,
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
        // swiftlint:enable function_parameter_count

        final public func changeTarget(_ target: UITableView) {
            generator.tableView = target
            viewHashValue = target.hashValue
            target.delegate = adapter
            target.dataSource = adapter
            target.reloadData()
        }

        @inlinable
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
        if let view = tableView.dequeue(cell: cell) {
            cellView = view
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
        let differenceSection = differenceSections[section]
        guard differenceSection.hasHeader, let header = differenceSection.header else { return nil }
        let headerView: UITableViewHeaderFooterView?
        if let view = tableView.dequeue(headerFooter: header) {
            headerView = view
        } else {
            tableView.register(headerFooter: header)
            headerView = tableView.dequeue(headerFooter: header)
        }
        guard let view = headerView else { return nil }
        header.bind(model: header.model, to: view, at: section)
        return view
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let differenceSection = differenceSections[section]
        guard differenceSection.hasFooter, let footer = differenceSection.footer else { return nil }
        let footerView: UITableViewHeaderFooterView?
        if let view = tableView.dequeue(headerFooter: footer) {
            footerView = view
        } else {
            tableView.register(headerFooter: footer)
            footerView = tableView.dequeue(headerFooter: footer)
        }
        guard let view = footerView else { return nil }
        footer.bind(model: footer.model, to: view, at: section)
        return view
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

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].willDisplay(view: cell, at: indexPath)
    }

    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section < differenceSections.count, indexPath.row < differenceSections[indexPath.section].cells.count else { return }
        differenceSections[indexPath.section].cells[indexPath.row].didEndDisplaying(view: cell, at: indexPath)
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        differenceSections[section].header?.willDisplay(view: view, at: section)
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard section < differenceSections.count, let view = view as? UITableViewHeaderFooterView
        else { return }
        differenceSections[section].header?.didEndDisplaying(view: view, at: section)
    }

    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        differenceSections[section].footer?.willDisplay(view: view, at: section)
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        differenceSections[section].footer?.didEndDisplaying(view: view, at: section)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didSelect(at: indexPath)
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        differenceSections[indexPath.section].cells[indexPath.row].didDeselect(at: indexPath)
    }
}

private extension TableView.ViewSourceProvider {
    final class PrototypeGenerator {
        var store: Store
        weak var tableView: UITableView?
        let sectionsGenerator: PrototypeSectionBlockGenerateFunction

        init(tableView: UITableView?, store: Store, generator: @escaping PrototypeSectionBlockGenerateFunction) {
            self.store = store
            self.tableView = tableView
            self.sectionsGenerator = generator
        }

        @inlinable
        func build() -> TableViewSectionBlock {
            guard let tableView = tableView else {
                return [TableView.Section()]
            }
            return sectionsGenerator(tableView, store)
        }
    }
}
