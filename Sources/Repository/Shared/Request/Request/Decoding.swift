//
//  File.swift
//  CoreRequest
//
//  Created by Robert on 7/21/19.
//

import Foundation

public protocol Decoding {
    var decoder: JSONDecoder { get }
}

extension Decoding {
    @inlinable
    public var decoder: JSONDecoder { .init() }
}
