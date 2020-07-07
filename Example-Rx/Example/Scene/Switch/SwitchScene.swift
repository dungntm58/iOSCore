//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase
import RxSwift

class SwitchScene: ViewableScene, Launchable, WorkflowSceneStepping {
    lazy var window = UIWindow(frame: UIScreen.main.bounds)
    lazy var isLoggedInSubject: PublishSubject<Bool> = .init()
    
    init() {
        let vc = AppStoryboard.main.viewController(of: SuperSwitcherViewController.self)
        vc.modalPresentationStyle = .fullScreen
        super.init(viewManager: vc)
    }

    override func perform(with object: Any?) {
        window.rootViewController = currentViewController
        window.makeKeyAndVisible()
    }
    
    func produceWorkflowItem() -> Observable<Bool> {
        isLoggedInSubject
    }
}
