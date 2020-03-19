//
//  BaseViewController.swift
//  RxCoreBase
//
//  Created by Robert on 1/10/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public typealias AttachableView = UIView & Appearant

open class BaseViewController: UIViewController {
    private(set) public lazy var attachedViews: [AttachableView] = []
    private(set) public var isViewAppeared: Bool = false

    open override func viewDidLoad() {
        super.viewDidLoad()

        func retrieveAttachedViews(in view: UIView) -> [AttachableView] {
            var attachedViews: [AttachableView] = []
            if view is Appearant {
                attachedViews.append(view as! AttachableView)
            }
            attachedViews.append(contentsOf: view.subviews.flatMap(retrieveAttachedViews))
            return attachedViews
        }

        attachedViews = retrieveAttachedViews(in: view)

        attachedViews.forEach { $0.didLoad?() }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewAppeared {
            attachedViews.forEach {
                $0.willReappear?(animated)
            }
        } else {
            attachedViews.forEach {
                $0.willAppear?(animated)
            }
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isViewAppeared {
            attachedViews.forEach {
                $0.didReappear?(animated)
            }
        } else {
            attachedViews.forEach {
                $0.didAppear?(animated)
            }
        }
        isViewAppeared = true
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        attachedViews.forEach {
            $0.willDisappear?(animated)
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attachedViews.forEach {
            $0.didDisappear?(animated)
        }
    }

    public func add(attachedView: AttachableView) {
        if attachedViews.contains(where: { $0 === attachedView }) {
            return
        }
        attachedViews.append(attachedView)
    }

    public func remove(attachedView: AttachableView) {
        // ??? I don't know why swift compiler can not compile this code
        // let index = attachedViews.firstIndex(of: attachedView)
        if let index = attachedViews.firstIndex(where: { $0 === attachedView }) {
            attachedViews.remove(at: index)
        }
    }
}
