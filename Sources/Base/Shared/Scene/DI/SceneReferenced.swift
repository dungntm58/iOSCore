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
final public class SceneReferenced<S>: ViewControllerAssociated {

    public init() {}

    private weak var viewController: UIViewController?
    private var weakScene: AnyWeak?

    public func associate(with viewController: UIViewController) {
        self.viewController = viewController
        guard weakScene == nil else { return }
        weakScene = ReferenceManager.getScene(associatedWith: viewController).map(AnyWeak.init(value:))
    }

    public var wrappedValue: S? {
        if let scene = weakScene?.value as? S { return scene }
        guard let viewController = viewController else { return nil }
        let scene: S? = ReferenceManager.getScene(associatedWith: viewController)
        weakScene = (scene as AnyObject?).map(AnyWeak.init(value:))
        return scene
    }
}

extension UIViewController {
    @objc dynamic func configAssociation() {
        Mirror(reflecting: self)
            .children
            .compactMap { $0.value as? ViewControllerAssociated }
            .forEach { $0.associate(with: self) }
    }
}
