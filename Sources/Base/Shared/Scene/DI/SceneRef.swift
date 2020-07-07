//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/15/19.
//

public protocol SceneRefAssociated {
    func associate(with viewController: UIViewController)
}

@propertyWrapper
final public class SceneRef<S>: SceneRefAssociated where S: Scenable {

    public init() {}

    private var viewControllerHash: Int?

    public func associate(with viewController: UIViewController) {
        self.viewControllerHash = viewController.hashValue
    }

    public var wrappedValue: S? {
        guard let viewControllerHash = viewControllerHash else { return nil }
        return RefManager.getScene(viewControllerHash)
    }
}
