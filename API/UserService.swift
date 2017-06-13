//
//  UserService.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import AERecord

class UserService {
    let networking: AuthorizedNetworking

    let disposeBag = DisposeBag()

    init(networking: AuthorizedNetworking) {
        self.networking = networking
    }

    func refreshCurrentUser() -> Observable<CachedItemsResult<User>> {
        return networking.provider
            .request(BasketAuthenticatedAPI.me)
            .map { try $0.mapJSONDictionry() }
            .map { try self.parseAndCreateUserFrom(json: $0) }
            .map { CachedItemsResult.success(item: $0) }
            .do(onNext: { _ in
                try! AERecord.Context.default.save()
            })
            .catchError({ (error) -> Observable<CachedItemsResult<User>> in
                return Observable.just(CachedItemsResult.error)
            }).shareReplay(1)
    }

    func updateCurrentUser(details: ProfileDetails) -> Observable<UpdateUserResult> {

        return networking.provider
            .request(BasketAuthenticatedAPI.updateUser(details))
            .map { try $0.mapJSONDictionry() }
            .map { try self.parseAndCreateUserFrom(json: $0) }
            .map { UpdateUserResult.success(user: $0) }
            .do(onNext: { _ in
                try! AERecord.Context.default.save()
            })
            .catchError({ (error) -> Observable<UpdateUserResult> in
                return Observable.just(UpdateUserResult.error(error: "error with updating user"))
            }).shareReplay(1)
    }

    private func parseAndCreateUserFrom(json: JSONDictionary) throws -> User {
        let user = try User.createWith(jsonDictionary: json)
        return user
    }

}
