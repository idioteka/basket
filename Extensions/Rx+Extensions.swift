//
//  Rx+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 23/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

public extension ObservableType {
    /**
     Maps and filters nil
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */

    public func mapAndFilterNil<T>(_ closure: @escaping (E) -> (T?)) -> Observable<T> {
        return self.flatMap { element -> Observable<T> in
            guard let value = closure(element) else {
                return Observable<T>.empty()
            }
            return Observable<T>.just(value)
        }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    /**
     Maps and filters nil
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */
    
    public func mapAndFilterNil<T>(_ closure: @escaping (E) -> (T?)) -> Driver<T> {
        return self.flatMap { element -> Driver<T> in
            guard let value = closure(element) else {
                return Driver<T>.empty()
            }
            return Driver<T>.just(value)
        }
    }
    
}

extension ObservableType where E: CachedResultType {
    typealias T = E.T

    func filterSuccess() -> Observable<T> {
        return self.flatMap { element -> Observable<T> in
            guard let value = element.resultIfSuccess() else {
                return Observable<T>.empty()
            }
            return Observable<T>.just(value)
        }
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E: CachedResultType {
    typealias T = E.T

    func filterSuccess() -> Driver<T> {
        return self.flatMap { element -> Driver<T> in
            guard let value = element.resultIfSuccess() else {
                return Driver<T>.empty()
            }
            return Driver<T>.just(value)
        }
    }

    func refreshing() -> Driver<Bool> {
        return self.map({ (e) -> Bool in
            return e.isRefreshing()
        })
    }
}

extension ObservableType {

    public func mapVoid() -> RxSwift.Observable<()> {
        return self.map { _ in () }
    }

}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {

    public func mapVoid() -> Driver<()> {
        return self.map { _ in () }
    }
}
