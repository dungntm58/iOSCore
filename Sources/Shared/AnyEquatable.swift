//
//  AnyEquatable.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/6/20.
//

import Foundation

public struct AnyEquatable {
    private let box: AnyEquatableBox
    public var base: Any { box.base }

    @usableFromInline
    init<E>(_ equatable: E) where E: Equatable {
        if let instance = equatable as? AnyEquatable {
            self = instance
        } else {
            box = Box(equatable)
        }
    }
}

extension AnyEquatable: Equatable {
    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.box.isEqual(to: rhs.box)
    }
}

private protocol AnyEquatableBox {
    var base: Any { get }
    func isEqual(to other: AnyEquatableBox) -> Bool
}

private extension AnyEquatable {
    struct Box<Base>: AnyEquatableBox where Base: Equatable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        init(_ base: Base) {
            self._base = base
        }

        @inlinable
        var base: Any { _base }

        func isEqual(to other: AnyEquatableBox) -> Bool {
            guard let otherBase = other.base as? Base else {
                switch base {
                case let hashable as AnyHashable:
                    if let otherHashable = other.base as? AnyHashable {
                        return hashable == otherHashable
                    }
                    return false
                default:
                    return false
                }
            }
            return _base == otherBase
        }
    }
}

extension Equatable {
    @inlinable
    public func eraseToAny() -> AnyEquatable { .init(self) }
}
