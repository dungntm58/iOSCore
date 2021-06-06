//
//  CollectionViewFunctionBuilder.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/7/20.
//

import Foundation

extension CollectionView {
    @usableFromInline
    struct SectionComponent: CollectionViewSectionComponent {
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

        @inlinable
        func asCells() -> [CollectionView.AnyCell] {
            cells
        }

        @inlinable
        func asHeaderFooter() -> (CollectionView.AnyHeaderFooter?, CollectionView.AnyHeaderFooter?) {
            (header, footer)
        }
    }

    @resultBuilder
    public struct SectionBlockBuilder {
        @inlinable
        public static func buildBlock(_ component: CollectionViewSectionBlock...) -> CollectionViewSectionBlock {
            component.flatMap { $0.sections }
        }

        @inlinable
        public static func buildExpression<Section>(_ expression: Section?) -> CollectionViewSectionBlock where Section: CollectionViewSection {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildExpression(_ expression: CollectionViewSectionBlock?) -> CollectionViewSectionBlock {
            if let component = expression {
                return component
            }
            return [AnySection]()
        }

        @inlinable
        public static func buildArray(_ component: [CollectionViewSectionBlock]) -> CollectionViewSectionBlock {
            component.flatMap { $0.sections }
        }

        @inlinable
        public static func buildIf(_ component: CollectionViewSectionBlock?) -> CollectionViewSectionBlock {
            if let component = component {
                return component
            }
            return [AnySection]()
        }

        @inlinable
        public static func buildEither(first: CollectionViewSectionBlock) -> CollectionViewSectionBlock {
            first
        }

        @inlinable
        public static func buildEither(second: CollectionViewSectionBlock) -> CollectionViewSectionBlock {
            second
        }

        @inlinable
        public static func buildOptional(_ component: CollectionViewSectionBlock?) -> CollectionViewSectionBlock {
            if let component = component {
                return component
            }
            return [AnySection]()
        }
    }

    @resultBuilder
    public struct SectionBuilder {
        @inlinable
        public static func buildBlock(_ components: CollectionViewSectionComponent...) -> CollectionViewSectionComponent {
            buildArray(components)
        }

        @inlinable
        public static func buildExpression(_ expression: CollectionViewSectionComponent?) -> CollectionViewSectionComponent {
            if let component = expression {
                return component
            }
            return [AnyCell]()
        }

        @inlinable
        public static func buildArray(_ components: [CollectionViewSectionComponent]) -> CollectionViewSectionComponent {
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
        public static func buildIf(_ component: CollectionViewSectionComponent?) -> CollectionViewSectionComponent {
            if let component = component {
                return component
            }
            return [AnyCell]()
        }

        @inlinable
        public static func buildEither(first: CollectionViewSectionComponent) -> CollectionViewSectionComponent {
            first
        }

        @inlinable
        public static func buildEither(second: CollectionViewSectionComponent) -> CollectionViewSectionComponent {
            second
        }

        @inlinable
        public static func buildOptional(_ component: CollectionViewSectionComponent?) -> CollectionViewSectionComponent {
            if let component = component {
                return component
            }
            return [AnyCell]()
        }
    }
}

@usableFromInline
func validateSectionBuilder(components: [CollectionViewSectionComponent]) -> Bool {
    let singleResponsibilityComponentCheck = components.allSatisfy {
        let headerFooter = $0.asHeaderFooter()
        return headerFooter.0 == nil || headerFooter.1 == nil || $0.asCells().isEmpty
    }
    guard singleResponsibilityComponentCheck else { return false }
    let headerPairs = components.enumerated()
        .compactMap { index, element -> (Int, CollectionView.AnyHeaderFooter)? in
            guard let headerFooter = element.asHeaderFooter().0, headerFooter.position == .header else { return nil }
            return (index, headerFooter)
        }
    let footerPairs = components.enumerated()
        .compactMap { index, element -> (Int, CollectionView.AnyHeaderFooter)? in
            guard let headerFooter = element.asHeaderFooter().1, headerFooter.position == .footer else { return nil }
            return (index, headerFooter)
        }
    guard headerPairs.isEmpty || headerPairs.count == 1 && headerPairs[0].0 == 0 else {
        return false
    }
    guard footerPairs.isEmpty || footerPairs.count == 1 && footerPairs[0].0 == components.count - 1 else {
        return false
    }
    return true
}
