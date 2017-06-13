//
//  ActivityViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 01/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import AERecord
import CoreData

class ActivityViewModel {

    let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService

    let basket: Driver<CachedItemsResult<Basket>>
    let activities: Driver<CachedItemsResult<[BasketActivity]>>

    fileprivate let basketId: Int
    fileprivate let userId: Int

    init(basketService: BasketService, basketId: Int, userId: Int, viewWillAppear: Observable<Void>) {
        self.basketService = basketService
        self.basketId = basketId
        self.userId = userId

        let activitiesFR: NSFetchRequest<BasketActivity> = BasketActivity.createFetchRequest(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)])

        let activitiesFRC: NSFetchedResultsController<BasketActivity> = NSFetchedResultsController(fetchRequest: activitiesFR, managedObjectContext: AERecord.Context.default, sectionNameKeyPath: nil, cacheName: nil)
        let activitiesObservable: Observable<[BasketActivity]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(activitiesFRC)

        let frc = Basket.fetchResultsControllerFor(id: basketId)

        let basketInCD: Observable<[Basket]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc).shareReplayLatestWhileConnected()

        let basketAndactivitiesInCD = Observable.combineLatest(activitiesObservable, basketInCD, resultSelector: {
            return $0.1
        })

        let refreshedBasket = viewWillAppear.flatMapLatest {
            return basketService.refreshBasketActivity(basketId: basketId)
        }

        let a = basketAndactivitiesInCD
            .mapAndFilterNil { $0.first }
            .map { CachedItemsResult.success(item: $0!) }

        let b = refreshedBasket
            .map { CachedItemsResult.success(item: $0) }
            .startWith(CachedItemsResult.loading)

        let c = Observable.of(a, b).merge()

        self.basket = c.asDriver(onErrorJustReturn: .error)

        self.activities = self.basket.map({
            result -> CachedItemsResult<[BasketActivity]> in
            switch result {
            case .error:
                return .error
            case .loading:
                return .loading
            case .success(let basket):
                let activities = basket.basketDetails?.activities?.allObjects as? [BasketActivity] ?? []
                return CachedItemsResult.success(item: activities.sorted { $0.id > $1.id } )
            }
        })

    }

}
