//
//  BasketsModel.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import AERecord
import CoreData

class BasketsListViewModel {

    let baskets: Driver<CachedItemsResult<[BasketViewModel]>>
    let refreshing: Driver<Bool>
    let firstBasket: Driver<Bool>
    let userId: Int
    let refreshBaskets = PublishSubject<Void>()

    fileprivate let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService

    init(basketService: BasketService, userId: Int, invitationAction: Observable<(BasketInvitationAction, Int)>, viewAppear: Observable<()>) {
        self.userId = userId

        let refreshCombined = Observable.of(viewAppear, refreshBaskets.asObservable()).merge()

        let refreshResult = refreshCombined
            .flatMapLatest { basketService.refreshBaskets() }
            .startWith(CachedItemsResult.loading)
            .shareReplayLatestWhileConnected()

        let refreshSuccess = refreshResult.map { $0.isSuccess }

        self.refreshing = refreshResult.map { $0.isRefreshing() }.asDriver(onErrorJustReturn: false).debug("refreshing")

        let databaseBaskets: Observable<[Basket]> = AERecord.Context.default.rx_entities()

        self.baskets = databaseBaskets
            .map {
                $0.map { BasketViewModel(
                    basketId: Int($0.id),
                    pending: $0.pending,
                    userId: userId
                    )
                }
            }
            .map { CachedItemsResult.success(item: $0) }
            .asDriver(onErrorJustReturn: .error)

        self.firstBasket = Observable.combineLatest(refreshSuccess, databaseBaskets, resultSelector: { (success, basketList) -> Bool in
            // TODO: if error don't show firstBasket
            return basketList.count == 0
        }).asDriver(onErrorJustReturn: false)

        self.basketService = basketService

        invitationAction.subscribe(onNext: { (action, basket) in
            basketService.sendInvitationAction(action: action, forBasketWithId: basket)
        }).addDisposableTo(disposeBag)
    }

    func isMine(basket: Basket) -> Bool {
        return basket.belongsToUserWith(id: userId)
    }
}
