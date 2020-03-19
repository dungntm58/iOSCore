//
//  Observable+Extension.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 5/18/19.
//

import RxSwift

public extension Observable where Element: Actionable {
    func of(types: [Element.ActionType]) -> Observable<Element> {
        filter { types.contains($0.type) }
    }

    func of(type: Element.ActionType...) -> Observable<Element> {
        filter { type.contains($0.type) }
    }
}
