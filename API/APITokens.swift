//
//  APITokens.swift
//  Basket
//
//  Created by Mario Radonic on 4/9/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import KeychainSwift

private enum TokenKeychainKey: String {
    case UserId
    case AccessToken
    case RefreshToken
}

// TODO: move to another file
enum JSONParsingError: Error {
    case genericError
}

struct APITokens {
    let userId: Int
    let accessToken: String
    let refreshToken: String

    init(userId: Int, accessToken: String, refreshToken: String) {
        self.userId = userId
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    init(json: JSONDictionary, userId: Int) throws {
        guard
            let accessToken = json["access_token"] as? String,
            let refreshToken = json["refresh_token"] as? String
        else {
            throw JSONParsingError.genericError
        }

        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
    }

    static func retreiveFromKeychain() throws -> APITokens {
        let keychain = KeychainSwift()

        guard
            let userId = Int(keychain.get(TokenKeychainKey.UserId) ?? ""),
            let accessToken = keychain.get(TokenKeychainKey.AccessToken),
            let refreshToken = keychain.get(TokenKeychainKey.RefreshToken)
        else {
            throw NSError(domain: "", code: 0, userInfo: nil) // TODO:
        }

        return APITokens(userId: userId, accessToken: accessToken, refreshToken: refreshToken)
    }

    func saveToKeychain() throws {
        try save(String(userId), toKey: .UserId)
        try save(accessToken, toKey: .AccessToken)
        try save(refreshToken, toKey: .RefreshToken)
    }

    static func deleteFromKeychain() {
        let keychain = KeychainSwift()
        keychain.delete(TokenKeychainKey.UserId.rawValue)
        keychain.delete(TokenKeychainKey.AccessToken.rawValue)
        keychain.delete(TokenKeychainKey.RefreshToken.rawValue)
    }

    fileprivate func save(_ string: String, toKey: TokenKeychainKey) throws {
        let keychain = KeychainSwift()

        if !keychain.set(string, forKey: toKey.rawValue) {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "error setting \(toKey.rawValue) in keychain"]) // TODO:
        }
    }
}

private extension KeychainSwift {
    func get(_ key: TokenKeychainKey) -> String? {
        return get(key.rawValue)
    }
}
