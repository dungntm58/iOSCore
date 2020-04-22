//
//  Observable+Extension.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 2/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift

extension Observable {
    @inlinable
    static public func first(_ source1: Observable, _ source2: Observable) -> Observable {
        source1.catchError { _ in source2 }
    }

    @inlinable
    public func mapToVoid() -> Observable<Void> {
        map { _ in }
    }
}
