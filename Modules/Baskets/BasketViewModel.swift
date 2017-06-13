//
//  BasketViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 4/17/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import AERecord
import RxDataSources

class BasketViewModel {
    let basketId: Int
    let pending: Bool

    let title: Driver<String>
    let descriptionString: Driver<String>
    let icon: Driver<String>
    let itemCount: Driver<Int>
    let yours: Driver<Bool>

    init(basketId: Int, pending: Bool, userId: Int) {
        self.basketId = basketId
        self.pending = pending

        let frc = Basket.fetchResultsControllerFor(id: basketId)

        let itemInCD: Observable<[Basket]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc).shareReplayLatestWhileConnected()

        let basket = itemInCD.map { $0.first }.filterNil().shareReplayLatestWhileConnected()

        self.title = basket.map { $0.name ?? "" }.asDriver(onErrorJustReturn: "")

        if pending {
            self.descriptionString = basket.map { $0.invitedBy?.name ?? "" }.map { "Invited by \($0)" }.asDriver(onErrorJustReturn: "")
        } else {
            self.descriptionString = basket.map { $0.detailString }.asDriver(onErrorJustReturn: "")
        }

        self.icon = basket.map { $0.icon?.toEmoji() ?? "" }.asDriver(onErrorJustReturn: "")
        self.itemCount = basket.map { Int($0.itemCount) }.asDriver(onErrorJustReturn: 0)
        self.yours = basket.map { $0.belongsToUserWith(id: userId) }.asDriver(onErrorJustReturn: false)
    }
}

extension BasketViewModel: IdentifiableType, Equatable {
    var identity: Int {
        return basketId + 1000 * pending.hashValue
    }
}

func ==(lhs: BasketViewModel, rhs: BasketViewModel) -> Bool {
    return lhs.identity == rhs.identity
}
