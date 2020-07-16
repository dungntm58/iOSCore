//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/15/19.
//

public protocol ViewControllerAssociated {
    func associate(with viewController: UIViewController)
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

extension UIViewController {
    @objc dynamic func configAssociation() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let sceneRef = child.value as? ViewControllerAssociated {
                sceneRef.associate(with: self)
            }
        }
    }
}
