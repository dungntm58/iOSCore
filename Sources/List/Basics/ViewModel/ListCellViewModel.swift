//
//  ListCellViewModel.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 12/18/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

class InternalCellModel: CellModel {
    var tag: Int
    var height: CGFloat
    let reuseIdentifier: String

    weak var section: SectionModel?
    let type: CellModelType

    init(type: CellModelType, reuseIdentifier: String?, height: CGFloat, tag: Int) {
        self.height = height
        self.type = type
        self.tag = tag

        if let reuseIdentifier = reuseIdentifier {
            self.reuseIdentifier = reuseIdentifier
            return
        }

        switch type {
        case .default:
            self.reuseIdentifier = "Cell"
        case .nib(let nibName, _):
            self.reuseIdentifier = nibName
        case .class(let `class`):
            self.reuseIdentifier = String(describing: `class`)
        }
    }
}

final class InternalHeaderFooterModel: InternalCellModel, HeaderFooterModel {
    let position: HeaderFooterPosition
    var customView: UIView?
    var title: String?

    init(type: CellModelType, reuseIdentifier: String?, position: HeaderFooterPosition, height: CGFloat, customView: UIView?, tag: Int) {
        self.position = position
        self.customView = customView
        super.init(type: type, reuseIdentifier: reuseIdentifier, height: height, tag: tag)
    }
}
