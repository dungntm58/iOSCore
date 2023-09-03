//
//  SwitchViewModel.swift
//  Example
//
//  Created by Robert on 03/09/2023.
//  Copyright © 2023 Robert Nguyen. All rights reserved.
//

import Combine

class SwitchViewModel {
    let tokenAvailibilityPublisher = PassthroughSubject<Bool, Never>()

    func checkToken() {
        tokenAvailibilityPublisher.send(AppPreferences.instance.token != nil)
    }
}
