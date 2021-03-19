//
//  CollectionViewFunctionBuilder.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/7/20.
//

import Foundation

extension CollectionView {
    @_functionBuilder
    public struct CellBlockBuilder {
        @inlinable
        public static func buildBlock(_ content: CollectionViewCellBlock...) -> CollectionViewCellBlock {
            content.flatMap { $0.cells }
        }

        @inlinable
        public static func buildIf(_ content: CollectionViewCellBlock?) -> CollectionViewCellBlock {
            if let content = content {
                return content
            } else {
                return [CollectionView.AnyCell]()
            }
        }

        @inlinable
        public static func buildEither(first: CollectionViewCellBlock) -> CollectionViewCellBlock {
            first
        }

        @inlinable
        public static func buildEither(second: CollectionViewCellBlock) -> CollectionViewCellBlock {
            second
        }
    }

    @_functionBuilder
    public struct SectionBlockBuilder {
        @inlinable
        public static func buildBlock(_ content: CollectionViewSectionBlock...) -> CollectionViewSectionBlock {
            content.flatMap { $0.sections }
        }

        @inlinable
        public static func buildIf(_ content: CollectionViewSectionBlock?) -> CollectionViewSectionBlock {
            if let content = content {
                return content
            } else {
                return [CollectionView.AnySection]()
            }
        }

        @inlinable
        public static func buildEither(first: CollectionViewSectionBlock) -> CollectionViewSectionBlock {
            first
        }

        @inlinable
        public static func buildEither(second: CollectionViewSectionBlock) -> CollectionViewSectionBlock {
            second
        }
    }

    @_functionBuilder
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
