//
//  NewBasketFriendsViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NewBasketFriendsViewModel: FriendsViewModel {
    let emptySearch: Driver<Void>
    let searchUserResults: Driver<[User]>
    let users: Driver<[User]>
    let completed: Driver<()>

    init(events: Driver<FriendsEvent>, searchService: SearchService, createService: CreateBasketService,
         firstStepData: Driver<CreateBasketFirstStepData>) {
        let searchChanged = events.filterSearch()
        let searchResults = searchChanged.debounce(0.4).distinctUntilChanged().flatMapLatest { (query) -> Driver<[User]> in
            if query.isEmpty {
                return Driver.just([])
            }
            return searchService.searchWithQuery(query).asDriver(onErrorJustReturn: [])
        }

        let addedUsers = events.filterAddUser().scan([User]()) { (alreadyAdded, user) -> [User] in
            var copy = alreadyAdded
            copy.insert(user, at: 0)
            return copy
        }.startWith([])

        self.searchUserResults = Driver.combineLatest(searchResults, addedUsers) { (results, alreadyAdded) -> [User] in
            return results.filter { !alreadyAdded.contains($0) }
        }.startWith([])

        self.users = addedUsers
        self.emptySearch = addedUsers.map { _ in () }

        let doneTapped = events.filterDoneTapped()

        let data = Driver.combineLatest(firstStepData, users, resultSelector: { $0 })

        self.completed = doneTapped.withLatestFrom(data).flatMapLatest { (firstStepData, users) -> Driver<()> in
            return createService.createBasketWithFirstStepData(firstStepData, andUsers: users).asDriver(onErrorDriveWith: Driver.empty())
        }
    }
}
