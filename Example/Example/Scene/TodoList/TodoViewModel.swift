//
//  TodoViewModel.swift
//  Example
//
//  Created by Robert on 4/11/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import Foundation

class TodoViewModel {
    var isAnimatedLoading: Bool

    var todos: [TodoEntity]

    init() {
        self.isAnimatedLoading = false
        self.todos = []
    }
}
