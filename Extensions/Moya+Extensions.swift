//
//  Moya+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 4/2/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Moya
import RxSwift

extension Response {
    func mapJSONDictionry() throws -> JSONDictionary {
        let json = try mapJSON()
        if let json = json as? JSONDictionary {
            return json
        }
        throw Moya.Error.underlying(NSError(domain: "", code: 0, userInfo: [:])) // TODO: throw meaningful error
    }
}

extension ObservableType where E == Response {
    func mapJSONDictionary() -> Observable<JSONDictionary> {
        return self.flatMap { (response) -> Observable<JSONDictionary> in
            let dic = try response.mapJSONDictionry()
            return Observable.just(dic)
        }
    }
}
