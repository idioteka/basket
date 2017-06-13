//
//  SearchService.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift

class SearchService {

    let networking: AuthorizedNetworking

    init(networking: AuthorizedNetworking) {
        self.networking = networking
    }

    func searchWithQuery(_ query: String) -> Observable<[User]> {
        let token = BasketAuthenticatedAPI.searchUsers(query)
        return networking.provider.request(token)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { response -> [User] in
                guard let response = response as? JSONDictionary else {
                    throw APIError.errorParsingJSON
                }

                let userJSONs = response.jsonArray("results") ?? []

                let users = userJSONs.flatMap { try? User.createWith(jsonDictionary: $0) }
                return users
            }
    }
}
