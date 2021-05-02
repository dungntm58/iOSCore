//
//  CollectionViewFunctionBuilder.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/7/20.
//

import Foundation

extension CollectionView {
    @resultBuilder
    public struct CellBlockBuilder {
        @inlinable
        public static func buildBlock(_ component: CollectionViewCellBlock...) -> CollectionViewCellBlock {
            component.flatMap { $0.cells }
        }

        @inlinable
        public static func buildExpression<Cell>(_ expression: Cell?) -> CollectionViewCellBlock where Cell: CollectionViewCell {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildExpression(_ expression: CollectionViewCellBlock?) -> CollectionViewCellBlock {
            if let component = expression {
                return component
            }
            return [CollectionView.AnyCell]()
        }

        @inlinable
        public static func buildArray(_ component: [CollectionViewCellBlock]) -> CollectionViewCellBlock {
            component.flatMap { $0.cells }
        }

        @inlinable
        public static func buildIf(_ component: CollectionViewCellBlock?) -> CollectionViewCellBlock {
            if let component = component {
                return component
            }
            return [CollectionView.AnyCell]()
        }

        @inlinable
        public static func buildEither(first: CollectionViewCellBlock) -> CollectionViewCellBlock {
            first
        }

        @inlinable
        public static func buildEither(second: CollectionViewCellBlock) -> CollectionViewCellBlock {
            second
        }

        @inlinable
        public static func buildOptional(_ component: CollectionViewCellBlock?) -> CollectionViewCellBlock {
            if let component = component {
                return component
            }
            return [CollectionView.AnyCell]()
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
            return [CollectionView.AnySection]()
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
            return [CollectionView.AnySection]()
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
            return [CollectionView.AnySection]()
        }
    }

    @resultBuilder
    public struct SectionBuilder<Header, Footer> where Header: CollectionViewHeaderFooter, Footer: CollectionViewHeaderFooter {
        @usableFromInline
        let header: Header?
        @usableFromInline
        let footer: Footer?
        @usableFromInline
        let cells: [AnyCell]

        @usableFromInline
        init(header: Header?, cells: [AnyCell] = [], footer: Footer?) {
            precondition(header == nil || header?.position == .header)
            precondition(footer == nil || footer?.position == .footer)

            self.header = header
            self.cells = cells
            self.footer = footer
        }

        @usableFromInline
        init(header: Header?, cellBlock: CollectionViewCellBlock..., footer: Footer?) {
            self.init(header: header, cells: cellBlock.flatMap { $0.cells }, footer: footer)
        }

        @usableFromInline
        init(header: Header?, cellBlocks: [CollectionViewCellBlock], footer: Footer?) {
            self.init(header: header, cells: cellBlocks.flatMap { $0.cells }, footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            .init(header: header, cells: cellBlock.cells, footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            .init(header: header,
                  cells: cellBlock1.cells + cellBlock2.cells,
                  footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            .init(header: header,
                  cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
                  footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ cellBlock4: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlock4.cells,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ cellBlock4: CollectionViewCellBlock,
            _ cellBlock5: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ cellBlock4: CollectionViewCellBlock,
            _ cellBlock5: CollectionViewCellBlock,
            _ cellBlock6: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ cellBlock4: CollectionViewCellBlock,
            _ cellBlock5: CollectionViewCellBlock,
            _ cellBlock6: CollectionViewCellBlock,
            _ cellBlock7: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ cellBlock4: CollectionViewCellBlock,
            _ cellBlock5: CollectionViewCellBlock,
            _ cellBlock6: CollectionViewCellBlock,
            _ cellBlock7: CollectionViewCellBlock,
            _ cellBlock8: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: CollectionViewCellBlock,
            _ cellBlock2: CollectionViewCellBlock,
            _ cellBlock3: CollectionViewCellBlock,
            _ cellBlock4: CollectionViewCellBlock,
            _ cellBlock5: CollectionViewCellBlock,
            _ cellBlock6: CollectionViewCellBlock,
            _ cellBlock7: CollectionViewCellBlock,
            _ cellBlock8: CollectionViewCellBlock,
            _ cellBlock9: CollectionViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                         footer: footer)
        }
    }
}

extension CollectionView.SectionBuilder where Header == CollectionView.AnyHeaderFooter {
    @inlinable
    public static func buildBlock(
        _ cellBlock: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        .init(header: nil, cells: cellBlock.cells, footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells,
              footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
              footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ cellBlock8: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ cellBlock8: CollectionViewCellBlock,
        _ cellBlock9: CollectionViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: footer)
    }
}

extension CollectionView.SectionBuilder where Footer == CollectionView.AnyHeaderFooter {
    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock: CollectionViewCellBlock
    ) -> Self {
        .init(header: header, cells: cellBlock.cells, footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock
    ) -> Self {
        .init(header: header,
              cells: cellBlock1.cells + cellBlock2.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock
    ) -> Self {
        .init(header: header,
              cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlock4.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ cellBlock8: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ cellBlock8: CollectionViewCellBlock,
        _ cellBlock9: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }
}

extension CollectionView.SectionBuilder where Header == CollectionView.AnyHeaderFooter, Footer == CollectionView.AnyHeaderFooter {
    @inlinable
    public static func buildBlock(_ cellBlock: CollectionViewCellBlock) -> Self {
        .init(header: nil, cells: cellBlock.cells, footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ cellBlock8: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: CollectionViewCellBlock,
        _ cellBlock2: CollectionViewCellBlock,
        _ cellBlock3: CollectionViewCellBlock,
        _ cellBlock4: CollectionViewCellBlock,
        _ cellBlock5: CollectionViewCellBlock,
        _ cellBlock6: CollectionViewCellBlock,
        _ cellBlock7: CollectionViewCellBlock,
        _ cellBlock8: CollectionViewCellBlock,
        _ cellBlock9: CollectionViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }
}
