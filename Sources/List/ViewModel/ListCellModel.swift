//
//  ListCellModel.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 12/17/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

public enum CellModelType {
    case `default`
    case nib(nibName: String, bundle: Bundle?)
    case `class`(`class`: AnyClass)

    func toCellModel() -> CellModel {
        return DefaultCellModel(type: self)
    }
}

public enum HeaderFooterPosition {
    case header
    case footer
}

public protocol CellModel {
    var type: CellModelType { get }
    var reuseIdentifier: String { get }
    var height: CGFloat { get }
}

public protocol HeaderFooterModel: CellModel {
    var customView: UIView? { get }
    var title: String? { set get }
    var position: HeaderFooterPosition { get }
}

public extension HeaderFooterModel {
    var customView: UIView? {
        return nil
    }
}
