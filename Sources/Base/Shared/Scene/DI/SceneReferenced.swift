//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/15/19.
//

public protocol ViewControllerAssociated {
    func associate(with viewController: UIViewController)
}

public protocol SceneAssociated {
    func associate(with scene: Scenable)
}

@propertyWrapper
final public class SceneReferenced<S>: ViewControllerAssociated where S: Scenable {

    public init() {}

    private weak var viewController: UIViewController?
    private weak var scene: S?

    public func associate(with viewController: UIViewController) {
        self.viewController = viewController
        guard scene == nil else { return }
        scene = ReferenceManager.getScene(associatedWith: viewController)
    }

    public var wrappedValue: S? {
        if let scene = scene { return scene }
        guard let viewController = viewController else { return nil }
        scene = ReferenceManager.getScene(associatedWith: viewController)
        return scene
    }
}
