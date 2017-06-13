//
//  Dictionary+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
//
//  Dictionary+Extensions.swift
//  Base
//
//  Created by Mario Radonic on 4/19/16.
//  Copyright © 2016 Five Agency. All rights reserved.
//

import Foundation

extension Dictionary where Key:ExpressibleByStringLiteral, Value: AnyObject {

    // MARK: String
    public func string(_ key: Key) -> String? {
        return self[key] as? String
    }

    public func string(_ key: Key, orThrow: Error) throws -> String {
        guard let val = string(key) else { throw orThrow }
        return val
    }

    public func stringOrThrow(_ key: Key) throws -> String {
        return try valueOrThrow(key)
    }

    // MARK: Double
    public func double(_ key: Key) -> Double? {
        return self[key] as? Double
    }

    public func doubleOrThrow(_ key: Key) throws -> Double {
        return try valueOrThrow(key)
    }

    // MARK: Int
    public func int(_ key: Key) -> Int? {
        return self[key] as? Int
    }

    public func intOrThrow(_ key: Key) throws -> Int {
        return try valueOrThrow(key)
    }

    // Mark: Bool
    public func bool(_ key: Key) -> Bool? {
        return self[key] as? Bool
    }

    public func bool(_ key: Key, or defaultValue: Bool) -> Bool {
        return bool(key) ?? defaultValue
    }

    public func boolOrThrow(_ key: Key) throws -> Bool {
        return try valueOrThrow(key)
    }

    // MARK: Json
    func jsonArray(_ key: Key) -> JSONArray? {
        return self[key] as? JSONArray
    }

    func jsonArrayOrThrow(_ key: Key) throws -> JSONArray {
        return try valueOrThrow(key)
    }

    func jsonDictionary(_ key: Key) -> JSONDictionary? {
        return self[key] as? JSONDictionary
    }

    func jsonDictionaryOrThrow(_ key: Key) throws -> JSONDictionary {
        return try valueOrThrow(key)
    }

    // MARK: Misc
    public func stringOrDoubleAsString(_ key: Key) -> String? {
        if let str = string(key) { return str }
        if let double = double(key) { return String(double) }

        return nil
    }

    public func anyAsString(_ key: Key) -> String? {
        if let val = self[key] {
            return "\(val)"
        }
        return nil
    }

    // MARK: Generic
    public func valueOrThrow<T>(_ key: Key) throws -> T {
        guard let val = self[key] as? T else {
            throw genericKeyErrorFor(key)
        }
        return val
    }
}

func genericKeyErrorFor<T: ExpressibleByStringLiteral>(_ key: T) -> Error {
    return NSError(domain: "Dictionary", code: -1, userInfo: [
        NSLocalizedDescriptionKey: "Dictionary doesn't contain key: \"\(key)\" of type \(T.self)"
        ])
}
