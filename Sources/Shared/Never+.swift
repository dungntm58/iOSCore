//
//  Never+.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/6/20.
//

import Foundation

func neverOccur() -> Never {
    preconditionFailure("This cannot be called")
}

extension Never: Identifiable {
    public var id: Never { neverOccur() }
}
