//
//  ListSectionViewModel.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 12/13/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

open class DefaultSectionModel: SectionModel {
    open var tag: Int = 0

    public let cells: [CellModel]

    private var _header: HeaderFooterModel?
    private var _footer: HeaderFooterModel?

    public init(cells: [CellModel], header: HeaderFooterModel? = nil, footer: HeaderFooterModel? = nil) {
        assert(header == nil || header?.position == .header, "Header position must be header")
        assert(footer == nil || footer?.position == .footer, "Footer position must be footer")
        self.cells = cells
        self._header = header
        self._footer = footer
    }

    public var header: HeaderFooterModel? {
        set {
            assert(newValue == nil || newValue?.position == .header, "Header position must be header")
            self._header = newValue
        }
        get {
            return _header
        }
    }

    public var footer: HeaderFooterModel? {
        set {
            assert(newValue == nil || newValue?.position == .footer, "Footer position must be footer")
            self._footer = newValue
        }
        get {
            return _footer
        }
    }
}
