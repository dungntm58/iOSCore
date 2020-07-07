//
//  RefManager+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import CoreRedux

extension RefManager {

    // Key: associated object hash value string
    // Value: weak ref of storable instance
    private static var storeDictionary: [String: Any] = [:]

    static func getStore<S>(_ hashValue: String) -> S? where S: Storable {
        (storeDictionary[hashValue] as? Weak<S>)?.value
    }

    static func setStore<S>(_ store: S?, associatedObjectHashValue hashValue: String) where S: Storable {
        storeDictionary[hashValue] = Weak(value: store)
        for (key, value) in storeDictionary {
            if let canBePruned = (value as? Prunable)?.canBePruned, canBePruned {
                storeDictionary[key] = nil
            }
        }
    }
}

public protocol StoreRefAssociated {
    func associate(with hashValue: String)
}

@propertyWrapper
public class StoreRef<S>: StoreRefAssociated where S: Storable {

    public init() {}

    private var associatedHashValue: String?
    private weak var store: S?

    public func associate(with hashValue: String) {
        self.associatedHashValue = hashValue
        guard let store = store else { return }
        RefManager.setStore(store, associatedObjectHashValue: hashValue)
    }

    public var wrappedValue: S? {
        set {
            self.store = newValue
        }
        get {
            if let store = store {
                return store
            }
            guard let associatedHashValue = associatedHashValue else { return nil }
            self.store = RefManager.getStore(associatedHashValue)
            return store
        }
    }
}
