//
//  TableViewSection.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation
import UIKit

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

        public init(id: ID, @SectionBuilder _ sectionBuilder: () -> TableViewSectionComponent) {
            self.id = id
            let builder = sectionBuilder()
            (self.header, self.footer) = builder.asHeaderFooter()
            self.cells = builder.asCells()
        }

        public func refine(@SectionBuilder _ sectionBuilder: () -> TableViewSectionComponent) -> Self {
            var other = self
            let builder = sectionBuilder()
            let builtHeaderFooter = builder.asHeaderFooter()
            (other.header, other.footer) = (header ?? builtHeaderFooter.0, footer ?? builtHeaderFooter.1)
            other.cells = builder.asCells()
            return other
        }
    }
}

extension TableView.Section where ID == UniqueIdentifier {
    @inlinable
    public init(@TableView.SectionBuilder _ sectionBuilder: () -> TableViewSectionComponent) {
        self.init(id: .init(), sectionBuilder)
    }

    @inlinable
    public init() {
        self.init(id: .init())
    }

    init(component: TableViewSectionComponent) {
        self.id = .init()
        (self.header, self.footer) = component.asHeaderFooter()
        self.cells = component.asCells()
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
