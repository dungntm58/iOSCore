//
//  FunctionBuilder.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/7/20.
//

import Foundation

extension TableView {
    @usableFromInline
    struct SectionComponent: TableViewSectionComponent {
        @usableFromInline
        let header: AnyHeaderFooter?
        @usableFromInline
        let footer: AnyHeaderFooter?
        @usableFromInline
        let cells: [AnyCell]

        @usableFromInline
        init(header: AnyHeaderFooter? = nil, cells: [AnyCell] = [], footer: AnyHeaderFooter? = nil) {
            assert(header == nil || header?.position == .header)
            assert(footer == nil || footer?.position == .footer)

            self.header = header
            self.cells = cells
            self.footer = footer
        }

        @usableFromInline
        init(header: AnyHeaderFooter?, cellBlock: TableViewSectionComponent..., footer: AnyHeaderFooter?) {
            self.init(header: header, cells: cellBlock.flatMap { $0.asCells() }, footer: footer)
        }

        @usableFromInline
        init(header: AnyHeaderFooter?, cellBlocks: [TableViewSectionComponent], footer: AnyHeaderFooter?) {
            self.init(header: header, cells: cellBlocks.flatMap { $0.asCells() }, footer: footer)
        }

        @inlinable
        func asCells() -> [TableView.AnyCell] {
            cells
        }

        @inlinable
        func asHeaderFooter() -> (TableView.AnyHeaderFooter?, TableView.AnyHeaderFooter?) {
            (header, footer)
        }
    }

    @resultBuilder
    public struct SectionBlockBuilder {
        @inlinable
        public static func buildBlock(_ component: TableViewSectionBlock...) -> TableViewSectionBlock {
            component.flatMap { $0.sections }
        }

        @inlinable
        public static func buildExpression<Section>(_ expression: Section?) -> TableViewSectionBlock where Section: TableViewSection {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildExpression(_ expression: TableViewSectionBlock?) -> TableViewSectionBlock {
            if let component = expression {
                return component
            }
            return [AnySection]()
        }

        @inlinable
        public static func buildArray(_ component: [TableViewSectionBlock]) -> TableViewSectionBlock {
            component.flatMap { $0.sections }
        }

        @inlinable
        public static func buildIf(_ component: TableViewSectionBlock?) -> TableViewSectionBlock {
            if let component = component {
                return component
            }
            return [AnySection]()
        }

        @inlinable
        public static func buildEither(first: TableViewSectionBlock) -> TableViewSectionBlock {
            first
        }

        @inlinable
        public static func buildEither(second: TableViewSectionBlock) -> TableViewSectionBlock {
            second
        }

        @inlinable
        public static func buildOptional(_ component: TableViewSectionBlock?) -> TableViewSectionBlock {
            if let component = component {
                return component
            }
            return [AnySection]()
        }
    }

    @resultBuilder
    public struct SectionBuilder {
        @inlinable
        public static func buildBlock(_ components: TableViewSectionComponent...) -> TableViewSectionComponent {
            buildArray(components)
        }

        @inlinable
        public static func buildExpression(_ expression: TableViewSectionComponent?) -> TableViewSectionComponent {
            if let component = expression {
                return component
            }
            return [AnyCell]()
        }

        @inlinable
        public static func buildArray(_ components: [TableViewSectionComponent]) -> TableViewSectionComponent {
            assert(validateSectionBuilder(components: components))
            let header = components.first?.asHeaderFooter().0
            let footer = components.last?.asHeaderFooter().1
            if header == nil && footer == nil {
                return components.flatMap { $0.asCells() }
            }
            let fromIndex = header == nil ? 0 : 1
            let toIndex = components.count - 1 - (footer == nil ? 0 : 1)
            return SectionComponent(
                header: header,
                cells: components[fromIndex...toIndex].flatMap { $0.asCells() },
                footer: footer
            )
        }

        @inlinable
        public static func buildIf(_ component: TableViewSectionComponent?) -> TableViewSectionComponent {
            if let component = component {
                return component
            }
            return [AnyCell]()
        }

        @inlinable
        public static func buildEither(first: TableViewSectionComponent) -> TableViewSectionComponent {
            first
        }

        @inlinable
        public static func buildEither(second: TableViewSectionComponent) -> TableViewSectionComponent {
            second
        }

        @inlinable
        public static func buildOptional(_ component: TableViewSectionComponent?) -> TableViewSectionComponent {
            if let component = component {
                return component
            }
            return [AnyCell]()
        }
    }
}

@usableFromInline
func validateSectionBuilder(components: [TableViewSectionComponent]) -> Bool {
    let singleResponsibilityComponentCheck = components.allSatisfy {
        let headerFooter = $0.asHeaderFooter()
        return headerFooter.0 == nil || headerFooter.1 == nil || $0.asCells().isEmpty
    }
    guard singleResponsibilityComponentCheck else { return false }
    let headerPairs = components.enumerated()
        .compactMap { index, element -> (Int, TableView.AnyHeaderFooter)? in
            guard let c = element.asHeaderFooter().0, c.position == .header else { return nil }
            return (index, c)
        }
    let footerPairs = components.enumerated()
        .compactMap { index, element -> (Int, TableView.AnyHeaderFooter)? in
            guard let c = element.asHeaderFooter().1, c.position == .footer else { return nil }
            return (index, c)
        }
    guard headerPairs.isEmpty || headerPairs.count == 1 && headerPairs[0].0 == 0 else {
        return false
    }
    guard footerPairs.isEmpty || footerPairs.count == 1 && footerPairs[0].0 == components.count - 1 else {
        return false
    }
    return true
}
