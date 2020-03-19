//
//  File.swift
//  CoreRequest
//
//  Created by Robert on 7/21/19.
//

import Combine

public protocol Decoding {
    var decoder: JSONDecoder { get }
}
