//
//  ViewManager.swift
//  CoreBase
//
//  Created by Robert on 7/21/19.
//

import RxSwift
import RxCocoa

open class ViewManager: SceneAssociated {
    private var _currentViewController: UIViewController?
    private var rootViewController: UIViewController
    private lazy var disposeBag = DisposeBag()
    fileprivate(set) public weak var scene: Scened?

    public init(viewController: UIViewController) {
        self.rootViewController = viewController
        self._currentViewController = viewController
        addHook(viewController)
    }

    public func associate(with scene: Scened) {
        self.scene = scene
        ReferenceManager.setScene(scene, associatedViewController: currentViewController)
    }
}

extension ViewManager: ViewManagable {
    private(set) public var currentViewController: UIViewController {
        get { _currentViewController ?? rootViewController }
        set {
            if _currentViewController != nil {
                _currentViewController = newValue
            }
        }
    }

    @inlinable
    public func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Present view controller", type(of: viewController))
        #endif
        addHook(viewController)
        self.currentViewController.present(viewController, animated: true, completion: completion)
    }

    @inlinable
    public func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Push view controller", type(of: viewController))
        #endif
        addHook(viewController)
        (self.currentViewController as? UINavigationController ?? self.currentViewController.navigationController)?.pushViewController(viewController, animated: true)
    }

    @inlinable
    public func show(_ viewController: UIViewController, sender: Any? = nil) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Show view controller", type(of: viewController))
        #endif
        addHook(viewController)
        self.currentViewController.show(viewController, sender: sender)
    }

    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Dismiss root view controller")
        #endif
        internalDismiss(from: rootViewController, animated: flag, completion: completion)
        scene?.detach()
    }

    public func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Dismiss current view controller")
        #endif
        let currentIsRoot = currentViewController == rootViewController
        internalDismiss(from: currentViewController, animated: flag, completion: completion)
        if currentIsRoot {
            scene?.detach()
        }
    }
}

extension ViewManager {
    @usableFromInline
    func addHook(_ viewController: UIViewController) {
        if let scene = scene {
            ReferenceManager.setScene(scene, associatedViewController: viewController)
        }

        Observable
            .combineLatest(
                viewController.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))),
                Observable.just(viewController)
            ) { $1 }
            .withUnretained(self)
            .subscribe(onNext: { $0.currentViewController = $1 })
            .disposed(by: disposeBag)

        switch viewController.modalPresentationStyle {
        case .fullScreen, .currentContext:
            break
        case .formSheet, .pageSheet:
            if #available(iOS 13.0, *) {
                addHookViewWillDisappear(viewController)
            }
        case .popover:
            if #available(iOS 13.0, *) {
                addHookViewWillDisappear(viewController)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                addHookViewWillDisappear(viewController)
            }
        default:
            addHookViewWillDisappear(viewController)
        }
    }

    private func addHookViewWillDisappear(_ viewController: UIViewController) {
        Observable
            .combineLatest(
                viewController.rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))),
                Observable.just(viewController)
            ) { $1 }
            .withUnretained(self)
            .subscribe(onNext: {
                guard let presentingViewController = $1.presentingViewController else { return }
                $0._currentViewController = presentingViewController
            })
            .disposed(by: disposeBag)
    }

    @inlinable
    func internalDismiss(from viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let naviViewController = viewController.navigationController {
            if naviViewController.viewControllers.first == viewController {
                naviViewController.dismiss(animated: flag, completion: completion)
            } else if let completion = completion {
                naviViewController.popViewController(animated: true, completion: completion)
            } else {
                naviViewController.popViewController(animated: true)
            }
        } else if let tabbarViewController = viewController.tabBarController {
            tabbarViewController.dismiss(animated: flag, completion: completion)
        } else {
            viewController.dismiss(animated: flag, completion: completion)
        }
    }
}
