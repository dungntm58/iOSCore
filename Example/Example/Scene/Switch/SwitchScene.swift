//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CoreBase
import CoreMacros
import Combine

@Scene
actor SwitchScene: Launchable {
    var viewModel: SwitchViewModel
    
    var cancellables = Set<AnyCancellable>()

    init(viewModel: SwitchViewModel = .init()) {
        self.viewModel = viewModel
    }

    func perform(with object: Any?) async {
        if await self.viewModel.checkToken() {
            await `switch`(to: TodoScene(), with: nil)
        } else {
            await `switch`(to: LoginScene(), with: nil)
        }
    }
}
