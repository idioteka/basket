//
//  CreateBasketService.swift
//  Basket
//
//  Created by Mario Radonic on 4/24/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import AERecord

class CreateBasketService {
    let networking: AuthorizedNetworking

    init(networking: AuthorizedNetworking) {
        self.networking = networking
    }

    func createBasketWithFirstStepData(_ firstData: CreateBasketFirstStepData, andUsers: [User]) -> Observable<Void> {
        let token = BasketAuthenticatedAPI.createBasket(firstStepData: firstData, users: andUsers.map { Int($0.id) })

        return networking.provider.request(token).filterSuccessfulStatusCodes().mapJSONDictionary().map { (json) -> () in
            _ = try Basket.createWith(json, pending: false)
            try AERecord.Context.default.save()
        }
    }
}
