//
//  Viewable.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 6/6/19.
//

import RxSwift
import RxRelay

public protocol Viewable {
    var viewManager: ViewManager { get }
}

// Shortcut
public extension Viewable {
    var viewController: UIViewController {
        return viewManager.viewController
    }
}

// Wrap
public extension Viewable {
    func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        viewManager.present(viewController, animated: flag, completion: completion)
    }

    func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
        viewManager.pushViewController(viewController, animated: flag)
    }

    func show(_ viewController: UIViewController, sender: Any? = nil) {
        viewManager.show(viewController, sender: sender)
    }

    func dismiss(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        viewManager.dismiss(animated: flag, completion: completion)
    }
}

public class ViewManager {
    private lazy var disposeBag = DisposeBag()

    fileprivate var viewController: UIViewController

    public init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        addHook(viewController)
        self.viewController.present(viewController, animated: true, completion: completion)
    }

    func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
        addHook(viewController)
        (self.viewController as? UINavigationController ?? self.viewController.navigationController)?.pushViewController(viewController, animated: true)
    }

    func show(_ viewController: UIViewController, sender: Any? = nil) {
        addHook(viewController)
        self.viewController.show(viewController, sender: sender)
    }

    func dismiss(animated flag: Bool = true, completion: (() -> Void)? = nil) {
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

private extension ViewManager {
    func addHook(_ viewController: UIViewController) {
        let setViewController: (UIViewController) -> Void = {
            [weak self] viewController in
            self?.viewController = viewController
        }

        switch viewController {
        case let naviVC as UINavigationController:
            naviVC
                .rx
                .didShow
                .map { $0.viewController }
                .subscribe(onNext: setViewController)
                .disposed(by: disposeBag)
        case let tabBarVC as UITabBarController:
            tabBarVC
                .rx
                .didSelect
                .subscribe(onNext: setViewController)
                .disposed(by: disposeBag)
        default:
            break
        }

        viewController
            .rx
            .viewWillDisappear
            .compactMap { [weak viewController] _ in viewController?.presentingViewController }
            .subscribe(onNext: setViewController)
            .disposed(by: disposeBag)
    }
}

public extension Scene where Self: Viewable {
    func onDetach() {
        viewManager.dismiss()
    }
}
