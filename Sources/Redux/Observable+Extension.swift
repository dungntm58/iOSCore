//
//  Observable+Extension.swift
//  CoreCleanSwiftRedux
//
//  Created by Robert Nguyen on 5/18/19.
//

import RxSwift

public extension Observable where Element: Actionable {
    func of(type: Element.ActionType...) -> Observable<Element> {
        return filter { type.contains($0.type) }
    }
}
