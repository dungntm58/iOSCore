//
//  ReferenceManager+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import CoreRedux

extension ReferenceManager {

    // Key: associated object hash value string
    // Value: weak ref of storable instance
    private static var storeDictionary: [String: Prunable] = [:]

    static func getStore<S>(_ hashValue: String) -> S? where S: Storable {
        (storeDictionary[hashValue] as? Weak<S>)?.value
    }

    static func setStore<S>(_ store: S?, associatedObjectHashValue hashValue: String) where S: Storable {
        storeDictionary[hashValue] = Weak(value: store)
        for (key, value) in storeDictionary {
            if value.canBePruned {
                storeDictionary[key] = nil
            }
        }
    }
}

public protocol SceneStoreReferencedAssociated {
    func associate(with scene: Scenable)
}

@propertyWrapper
final public class SceneStoreReferenced<S>: SceneStoreReferencedAssociated where S: Storable {

    public init(wrappedValue: S?) {
        self.store = wrappedValue
    }

    private weak var scene: Scenable?
    private weak var store: S?
    private var isSceneConfig = false

    public func associate(with scene: Scenable) {
        self.scene = scene
        guard let store = store else { return }
        ReferenceManager.setStore(store, associatedObjectHashValue: scene.id)
        if isSceneConfig { return }
        scene.config(with: store)
        isSceneConfig = true
    }

    public var wrappedValue: S? {
        set {
            self.store = newValue
            guard let scene = scene, let store = newValue else { return }
            if isSceneConfig || self.store === store { return }
            scene.config(with: store)
            isSceneConfig = true
        }
        get {
            if let store = store { return store }
            guard let scene = scene else { return nil }
            self.store = ReferenceManager.getStore(scene.id)
            return store
        }
    }
}
