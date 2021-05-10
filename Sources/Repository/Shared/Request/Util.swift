//
//  Util.swift
//  CoreRequest
//
//  Created by Robert on 8/15/19.
//

@usableFromInline
func += <K, V> ( left: inout [K: V], right: [K: V]) {
    for (key, value) in right {
        left.updateValue(value, forKey: key)
    }
}

@usableFromInline
func + <K, V>(lhs: [K: V], rhs: [K: V]) -> [K: V] {
    var res: [K: V] = lhs
    res += rhs
    return res
}

#if !RELEASE && !PRODUCTION
@usableFromInline
func printDebug(data: Data) {
    do {
        let serialization = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        switch serialization {
        case let dict as [String: Any]:
            Swift.print("Response represents", dict)
        case let array as [Any]:
            Swift.print("Response represents", array)
        default:
            Swift.print("Response string represents", String(data: data, encoding: .utf8) as Any)
        }
    } catch {
        Swift.print("Response string represents", String(data: data, encoding: .utf8) as Any)
    }
}
#endif
