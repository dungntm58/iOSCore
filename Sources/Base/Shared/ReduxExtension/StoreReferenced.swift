//
//  ReferenceManager+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import CoreRedux

@propertyWrapper
final public class SceneStoreReferenced<S>: SceneAssociated, ViewControllerAssociated where S: Storable {

    public init(wrappedValue: S?, keyPath: String? = nil) {
        self.store = wrappedValue
        self.keyPath = keyPath
    }

    public init<Root, Value>(wrappedValue: S?, keyPath: KeyPath<Root, Value>? = nil) where Root: Scenable {
        self.store = wrappedValue
        self.keyPath = keyPath.map(String.init(describing:))
    }

    private let keyPath: String?
    private weak var scene: Scenable?
    private weak var viewController: UIViewController?
    private var store: S?
    private var isSceneConfig = false

    public func associate(with scene: Scenable) {
        self.scene = scene
        guard let store = store else { return }
        if isSceneConfig { return }
        scene.config(with: store)
        isSceneConfig = true
    }

    public func associate(with viewController: UIViewController) {
        self.viewController = viewController
        self.scene = ReferenceManager.getAbstractScene(associatedWith: viewController)
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
            guard let scene = scene else {
                guard let viewController = viewController,
                    let scene = ReferenceManager.getAbstractScene(associatedWith: viewController) else { return nil }
                self.scene = scene
                self.store = scene.getStore(keyPath: keyPath)
                return store
            }
            self.store = scene.getStore(keyPath: keyPath)
            return store
        }
    }
}

extension Scenable {
    func getStore<Store>(keyPath: String?) -> Store? where Store: Storable {
        let mirror = Mirror(reflecting: self)
        let storeChildren = mirror.children.filter { $0.value is Store }
        if keyPath == nil {
            if storeChildren.count == 1 {
                return storeChildren.first?.value as? Store
            }
            return nil
        }
        return mirror.children.first(where: { $0.label == keyPath })?.value as? Store
    }
}
