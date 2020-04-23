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
    public var hasHeader: Bool {
        guard let header = header else {
            return false
        }
        return header.position == .header
    }

    public var hasFooter: Bool {
        guard let footer = footer else {
            return false
        }
        return footer.position == .footer
    }

    @inlinable
    public func eraseToAny() -> TableView.AnySection { .init(self) }

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
    public struct Section<ID>: TableViewSection, TableViewSectionBlock where ID: Hashable {
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

        public func refine<Header, Footer>(header: Header?, footer: Footer?, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
            precondition(header == nil || header?.position == .header)
            precondition(footer == nil || footer?.position == .footer)

            var other = self
            other.header = header?.eraseToAny()
            other.footer = footer?.eraseToAny()
            other.cells = CellBlockBuilder().cells
            return other
        }

        public func refine<Header>(header: Header?, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self where Header: TableViewHeaderFooter {
            return refine(header: header, footer: footer, CellBlockBuilder)
        }

        public func refine<Footer>(footer: Footer?, @CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self where Footer: TableViewHeaderFooter {
            return refine(header: header, footer: footer, CellBlockBuilder)
        }

        public func refine(@CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) -> Self {
            return refine(header: header, footer: footer, CellBlockBuilder)
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
    public init(@TableView.CellBlockBuilder _ CellBlockBuilder: () -> TableViewCellBlock) {
        self.init(id: .init(), CellBlockBuilder)
    }

    public init() {
        self.init(id: .init())
    }
}

public protocol TableViewSectionBlock {
    var sections: [TableView.AnySection] { get }
}

extension TableViewSectionBlock where Self: TableViewSection {
    public var sections: [TableView.AnySection] { [eraseToAny()] }
}

extension Optional: TableViewSectionBlock where Wrapped: TableViewSection {
    public var sections: [TableView.AnySection] {
        switch self {
        case .none:
            return []
        case .some(let section):
            return [section.eraseToAny()]
        }
    }
}

extension Array: TableViewSectionBlock where Element: TableViewSectionBlock {
    public var sections: [TableView.AnySection] { flatMap { $0.sections } }
}

extension ForEach: TableViewSectionBlock where Content == TableViewSectionBlock {
    public var sections: [TableView.AnySection] { elements.flatMap { $0.sections } }

    @inlinable
    public init(_ data: Data, @TableView.SectionBlockBuilder content: (Int, Data.Element) -> TableViewSectionBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
