//
//  ListDataWorker.swift
//  CoreRedux-Rx
//
//  Created by Robert on 10/06/2021.
//

import Foundation

/* Some convenience methods to get list of objects
 * Catch event from any repository
 * Not constraint to any lower-level class
 */

import RxSwift
import CoreRepository

public protocol ListDataWorker {
    // swiftlint:disable type_name
    associatedtype T
    // swiftlint:enable type_name

    func getList(options: PaginationRequestOptions?) -> Observable<ListDTO<T>>
}

extension ListDataWorker {
    @inlinable
    public func eraseToAny() -> AnyListDataWorker { .init(self) }
}

public struct AnyListDataWorker: ListDataWorker {
    private let box: AnyListDataWorkerBox

    @usableFromInline
    init<Worker>(_ worker: Worker) where Worker: ListDataWorker {
        if let any = worker as? AnyListDataWorker {
            self = any
        } else {
            box = Box(worker)
        }
    }

    public func getList(options: PaginationRequestOptions?) -> Observable<ListDTO<Any>> {
        box.getList(options: options)
    }
}

private protocol AnyListDataWorkerBox {
    func getList(options: PaginationRequestOptions?) -> Observable<ListDTO<Any>>
}

private struct Box<Base>: AnyListDataWorkerBox where Base: ListDataWorker {
    let base: Base

    init(_ base: Base) {
        self.base = base
    }

    func getList(options: PaginationRequestOptions?) -> Observable<ListDTO<Any>> {
        base.getList(options: options)
            .map { ListDTO(data: $0.data, pagination: $0.pagination) }
    }
}
