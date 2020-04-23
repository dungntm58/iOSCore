//
//  Observable+Extension.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/18/19.
//

import RxSwift

public extension Observable where Element: Actionable {
    func of(types: [Element.ActionType]) -> Observable<Element> {
        if types.isEmpty { return self }
        return filter { types.contains($0.type) }
    }

    func of(type: Element.ActionType...) -> Observable<Element> {
        if type.isEmpty { return self }
        return filter { type.contains($0.type) }
    }
}
