//
//  Helper.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 3/23/19.
//

public protocol Storyboard {
    var name: String { get }
    var bundle: Bundle? { get }
}

public extension Storyboard {
    func viewController<ViewController>(of type: ViewController.Type, with identifier: String? = nil) -> ViewController where ViewController: UIViewController {
        return instantiate().instantiateViewController(withIdentifier: identifier ?? String(describing: ViewController.self)) as! ViewController
    }

    func instantiate() -> UIStoryboard {
        return UIStoryboard.init(name: name, bundle: bundle)
    }
}
