//
//  SwitchViewModel.swift
//  Example
//
//  Created by Robert on 03/09/2023.
//  Copyright © 2023 Robert Nguyen. All rights reserved.
//

import Combine
import CoreMacros

@SceneDependency
actor SwitchViewModel {
    func checkToken() -> Bool {
        AppPreferences.instance.token != nil
    }
}
