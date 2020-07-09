//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/15/19.
//

public protocol SceneReferencedAssociated {
    func associate(with viewController: UIViewController)
}

@propertyWrapper
final public class SceneReferenced<S>: SceneReferencedAssociated where S: Scenable {

    public init() {}

    private weak var viewController: UIViewController?
    private weak var scene: S?

    public func associate(with viewController: UIViewController) {
        self.viewController = viewController
    }

    public var wrappedValue: S? {
        if let scene = scene { return scene }
        guard let viewController = viewController else { return nil }
        scene = ReferenceManager.getScene(associatedWith: viewController)
        return scene
    }
}
