//
//  TupleContent.swift
//  CoreList
//
//  Created by Robert on 4/4/20.
//

import Foundation

@available(*, deprecated)
@frozen
public struct ForEach<Data, Content> where Data: RandomAccessCollection {
    public let data: Data
    public let elements: [Content]

    @usableFromInline
    init(_ data: Data, elements: [Content]) {
        self.data = data
        self.elements = elements
    }
}
