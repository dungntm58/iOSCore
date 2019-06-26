//
//  Observable+Extension.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 2/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift

public extension Observable {
    static func first(_ source1: Observable, _ source2: Observable) -> Observable {
        return source1.catchError { _ in source2 }
    }
}
