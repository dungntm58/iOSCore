//
//  Foundation+Extension.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 6/6/19.
//

public extension Array {
    mutating func remove(element: Element) {
        guard let objIndex = firstIndex(where: { $0 as AnyObject === element as AnyObject }) else { return }
        remove(at: objIndex)
    }
}
