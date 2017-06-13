//
//  CachedItemsResult.swift
//  Basket
//
//  Created by Mario Radonic on 4/16/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

protocol CachedResultType {
    associatedtype T
//    var isSuccess: Bool { get }
    func resultIfSuccess() -> T?
    func isRefreshing() -> Bool
}

enum CachedItemsResult<T> {
    case success(item: T)
    case loading
    case error

    var isSuccess: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
}

extension CachedItemsResult: CachedResultType {
    func resultIfSuccess() -> T? {
        switch self {
        case .success(let item):
            return item
        default:
            return nil
        }
    }

    func isRefreshing() -> Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
}
