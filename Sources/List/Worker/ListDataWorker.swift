//
//  ListDataWorker.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import CoreCleanSwiftBase

/* Some convenience methods to get list of objects
 * Catch event from any repository
 * Not constraint to any lower-level class
 */

public protocol ListDataWorker {
    associatedtype T: Equatable

    func getList(options: PaginationRequest?) -> Observable<ListResponse<T>>
}
