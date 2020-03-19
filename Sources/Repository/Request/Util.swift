//
//  Util.swift
//  CoreRequest
//
//  Created by Robert on 8/15/19.
//

func += <K, V> ( left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

func + <K, V>(lhs: [K:V], rhs: [K:V]) -> [K:V] {
    var res: [K:V] = lhs
    res += rhs
    return res
}
