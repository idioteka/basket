//
//  ExistingBasketFriendsViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 4/24/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData
import AERecord

class ExistingBasketFriendsViewModel: FriendsViewModel {
    let emptySearch: Driver<Void>
    let searchUserResults: Driver<[User]>
    let users: Driver<[User]>

    init(basketId: Int, events: Driver<FriendsEvent>, searchService: SearchService, basketService: BasketService) {
        let searchChanged = events.filterSearch()
        let searchResults = searchChanged.debounce(0.4).distinctUntilChanged().flatMapLatest { (query) -> Driver<[User]> in
            if query.isEmpty {
                return Driver.just([])
            }
            return searchService.searchWithQuery(query).asDriver(onErrorJustReturn: [])
        }

        // Refresh the basket on every view will appear
        let viewAppear = events.filterViewWillAppear()
        let refreshedBasket = viewAppear.map { () -> Basket? in
            return Basket.first(with: "id", value: basketId)
        }.filterNil()

        let basketDetails = refreshedBasket.map { $0.basketDetails }.filterNil()
        let allUsers = basketDetails.map { $0.allUsers }

        let addUsersSuccess = events.filterAddUser().flatMap { (user) -> Driver<User> in
            return basketService.inviteUserWithId(userId: Int(user.id), toBasketWithId: basketId)
                .map { user }.asDriver(onErrorDriveWith: Driver.empty())
        }

        self.users = allUsers.flatMapLatest { (allUsers) -> Driver<[User]> in
            return addUsersSuccess.scan(allUsers) { (alreadyAdded, userToAdd) -> [User] in
                var copy = alreadyAdded
                copy.insert(userToAdd, at: 0)
                return copy
            }.startWith(allUsers)
        }

        self.searchUserResults = Driver.combineLatest(searchResults, self.users) { (results, alreadyAdded) -> [User] in
            return results.filter { !alreadyAdded.contains($0) }
        }.startWith([])

        self.emptySearch = events.filterAddUser().map { _ in () }

    }
}
