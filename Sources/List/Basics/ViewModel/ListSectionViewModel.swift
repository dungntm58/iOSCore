//
//  ListSectionViewModel.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 12/13/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

final class InternalSectionModel: SectionModel {
    private var _header: HeaderFooterModel?
    private var _footer: HeaderFooterModel?

    var cells: [CellModel]
    var tag: Int = 0

    init(cells: [CellModel], header: HeaderFooterModel? = nil, footer: HeaderFooterModel? = nil) {
        assert(header == nil || header?.position == .header, "Header position should be header")
        assert(footer == nil || footer?.position == .footer, "Footer position should be footer")
        self.cells = cells
        self._header = header
        self._footer = footer
    }

    var header: HeaderFooterModel? {
        set {
            assert(newValue == nil || newValue?.position == .header, "Header position should be header")
            self._header = newValue
        }
        get { _header }
    }

    var footer: HeaderFooterModel? {
        set {
            assert(newValue == nil || newValue?.position == .footer, "Footer position should be footer")
            self._footer = newValue
        }
        get { _footer }
    }
}
