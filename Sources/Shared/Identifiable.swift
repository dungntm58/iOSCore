//
//  Identifiable.swift
//  Shared
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol Identifiable {
    associatedtype ID: Hashable

    var id: ID { get }
}

extension Identifiable where Self: Hashable {
    public var id: Self { self }
}

extension Identifiable {
    @inlinable
    public func eraseToAny() -> AnyIdentifiable { .init(self) }
}

public struct AnyIdentifiable: Identifiable {
    private let box: AnyIdentifiableBox
    public var base: Any { box.base }

    public var id: AnyHashable { box.id }

    @usableFromInline
    init<Base>(_ base: Base) where Base: Identifiable {
        if let _identifiable = base as? AnyIdentifiable {
            self = _identifiable
        } else {
            box = IdentifiableBox(base)
        }
    }
}

private protocol AnyIdentifiableBox {
    var base: Any { get }
    var id: AnyHashable { get }
}

private extension AnyIdentifiable {
    struct IdentifiableBox<Base>: AnyIdentifiableBox where Base: Identifiable {
        @usableFromInline
        let base: Any
        @usableFromInline
        let id: AnyHashable

        @usableFromInline
        init(_ base: Base) {
            self.base = base
            self.id = base.id
        }
    }
}
