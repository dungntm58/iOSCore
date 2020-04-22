//
//  BaseViewController.swift
//  RxCoreBase
//
//  Created by Robert on 1/10/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseViewController: UIViewController {
    private(set) public var isViewAppeared: Bool = false

    var apparents: [Apparent] { retrieveApparentViews(in: view) }

    open override func viewDidLoad() {
        super.viewDidLoad()

        apparents.forEach { $0.didLoad?() }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewAppeared {
            apparents.forEach {
                $0.willReappear?(animated)
            }
        } else {
            apparents.forEach {
                $0.willAppear?(animated)
            }
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isViewAppeared {
            apparents.forEach {
                $0.didReappear?(animated)
            }
        } else {
            apparents.forEach {
                $0.didAppear?(animated)
            }
        }
        isViewAppeared = true
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        apparents.forEach {
            $0.willDisappear?(animated)
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apparents.forEach {
            $0.didDisappear?(animated)
        }
    }
}

private func retrieveApparentViews(in view: UIView) -> [Apparent] {
    var results: [Apparent] = []
    if let apparent = view as? Apparent {
        results.append(apparent)
    }
    results.append(contentsOf: view.subviews.flatMap(retrieveApparentViews))
    return results
}
