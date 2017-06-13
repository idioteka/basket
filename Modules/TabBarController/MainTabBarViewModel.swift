//
//  MainTabBarViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 17/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AERecord

class MainTabBarViewModel {

    let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService

    fileprivate let basketId: Int
    let basket: Driver<CachedItemsResult<Basket>>

    init(basketService: BasketService, basketId: Int) {
        self.basketService = basketService
        self.basketId = basketId

        let frc = Basket.fetchResultsControllerFor(id: basketId)

        let basketInCD: Observable<[Basket]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc)

        let refreshedBasket = basketService.refreshBasketWith(id: basketId)

        let a = basketInCD.map { $0.first }.filter { $0 != nil }.map { CachedItemsResult.success(item: $0!) }
        let b = refreshedBasket.map { CachedItemsResult.success(item: $0) }.startWith(CachedItemsResult.loading)

        let c = Observable.of(a, b).merge()

        self.basket = c.asDriver(onErrorJustReturn: .error)
    }
}
