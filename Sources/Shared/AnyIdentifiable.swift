//
//  AnyIdentifiable.swift
//  Shared
//
//  Created by Robert on 25/12/2021.
//

import Foundation

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
        if let instance = base as? AnyIdentifiable {
            self = instance
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
