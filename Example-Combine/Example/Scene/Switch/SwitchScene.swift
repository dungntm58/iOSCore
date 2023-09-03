//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CoreBase
import Combine

class SwitchScene: Scene, Launchable {
    @SceneDependency var viewModel: SwitchViewModel?

    var cancellables = Set<AnyCancellable>()

    init(viewModel: SwitchViewModel = SwitchViewModel()) {
        super.init()
        self.viewModel = viewModel

        viewModel.tokenAvailibilityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isTokenValid in
                if isTokenValid {
                    self?.switch(to: TodoScene(), with: nil)
                } else {
                    self?.switch(to: LoginScene(), with: nil)
                }
            }
            .store(in: &cancellables)
    }

    override func perform(with object: Any?) {
        viewModel?.checkToken()
    }
}
