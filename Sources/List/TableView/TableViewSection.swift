//
//  TableViewSection.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

@frozen public enum TableView {}

public protocol TableViewSection {
    associatedtype ID: Hashable

    var id: ID { get }
    var header: TableView.AnyHeaderFooter? { get }
    var footer: TableView.AnyHeaderFooter? { get }
    var cells: [TableView.AnyCell] { get }
}

extension TableViewSection {
    @inlinable
    public var hasHeader: Bool {
        guard let header = header else {
            return false
        }
        return header.position == .header
    }

    @inlinable
    public var hasFooter: Bool {
        guard let footer = footer else {
            return false
        }
        return footer.position == .footer
    }

    @inlinable
    public func eraseToAny() -> TableView.AnySection { .init(self) }

    @inlinable
    public func register(in tableView: UITableView) {
        if hasHeader {
            header.map { tableView.register(headerFooter: $0) }
        }
        if hasFooter {
            footer.map { tableView.register(headerFooter: $0) }
        }
        cells.forEach(tableView.register)
    }
}

extension TableView {
    @frozen
    public struct Section<ID>: TableViewSection where ID: Hashable {
        public let id: ID
        public internal(set) var header: AnyHeaderFooter?
        public internal(set) var footer: AnyHeaderFooter?
        public internal(set) var cells: [AnyCell]

        public init(id: ID) {
            self.id = id
            self.header = nil
            self.footer = nil
            self.cells = []
        }

        public init(id: ID, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) {
            self.id = id
            self.header = nil
            self.footer = nil
            self.cells = CellBlockBuilder().cells
        }

        public init<Header, Footer>(id: ID, @SectionBuilder<Header, Footer> _ SectionBuilder: () -> SectionBuilder<Header, Footer>) where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
            self.id = id
            let builder = SectionBuilder()
            self.header = builder.header?.eraseToAny()
            self.footer = builder.footer?.eraseToAny()
            self.cells = builder.cells
        }

        public func refine<Header, Footer>(header: Header?, footer: Footer?, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
            precondition(header == nil || header?.position == .header)
            precondition(footer == nil || footer?.position == .footer)

            var other = self
            other.header = header?.eraseToAny()
            other.footer = footer?.eraseToAny()
            other.cells = CellBlockBuilder().cells
            return other
        }

        @inlinable
        public func refine<Header>(header: Header?, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self where Header: TableViewHeaderFooter {
            refine(header: header, footer: footer, CellBlockBuilder)
        }

        @inlinable
        public func refine<Footer>(footer: Footer?, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self where Footer: TableViewHeaderFooter {
            refine(header: header, footer: footer, CellBlockBuilder)
        }

        @inlinable
        public func refine(@CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self {
            refine(header: header, footer: footer, CellBlockBuilder)
        }

        public func refine<Header, Footer>(@SectionBuilder<Header, Footer> _ SectionBuilder: () -> SectionBuilder<Header, Footer>) -> Self where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
            var other = self
            let builder = SectionBuilder()
            other.header = builder.header?.eraseToAny()
            other.footer = builder.footer?.eraseToAny()
            other.cells = builder.cells
            return other
        }
    }
}

extension TableView.Section where ID == UniqueIdentifier {
    @inlinable
    public init(@TableView.CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) {
        self.init(id: .init(), CellBlockBuilder)
    }

    @inlinable
    public init<Header, Footer>(@TableView.SectionBuilder<Header, Footer> _ SectionBuilder: () -> TableView.SectionBuilder<Header, Footer>) where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
        self.init(id: .init(), SectionBuilder)
    }

    @inlinable
    public init() {
        self.init(id: .init())
    }

    init<Header, Footer>(builder: TableView.SectionBuilder<Header, Footer>) where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
        self.id = .init()
        self.header = builder.header?.eraseToAny()
        self.footer = builder.footer?.eraseToAny()
        self.cells = builder.cells
    }
}

public protocol TableViewSectionBlock {
    var sections: [TableView.AnySection] { get }
}

extension TableViewSectionBlock where Self: TableViewSection {
    @inlinable
    public var sections: [TableView.AnySection] { [eraseToAny()] }
}

extension Array: TableViewSectionBlock where Element: TableViewSection {
    @inlinable
    public var sections: [TableView.AnySection] { map { $0.eraseToAny() } }
}

@available(*, deprecated)
extension ForEach: TableViewSectionBlock where Content == TableViewSectionBlock {
    @inlinable
    public var sections: [TableView.AnySection] { elements.flatMap { $0.sections } }

    @inlinable
    public init(_ data: Data, @TableView.SectionBlockBuilder content: (Int, Data.Element) -> TableViewSectionBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
