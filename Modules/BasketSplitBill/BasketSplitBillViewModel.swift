//
//  BasketSplitBillViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 12/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import CoreData
import AERecord

class BasketSplitBillViewModel {

    let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService
    fileprivate let basketId: Int
    fileprivate let userId: Int

    let basket: Driver<CachedItemsResult<Basket>>
    let billItems: Driver<CachedItemsResult<[BillItem]>>
    var totalAmountSpent: Double?

    init(basketService: BasketService, basketId: Int, userId: Int, viewWillAppear: Observable<Void>) {
        self.basketService = basketService
        self.basketId = basketId
        self.userId = userId

        if let basketObject = Basket.first(with: NSPredicate(format: "id = %d", basketId)) {
            totalAmountSpent = basketObject.bill?.total
        }

        let billItemsFR: NSFetchRequest<BillItem> = BillItem.createFetchRequest(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "person.id", ascending: true)])

        let billItemsFRC: NSFetchedResultsController<BillItem> = NSFetchedResultsController(fetchRequest: billItemsFR, managedObjectContext: AERecord.Context.default, sectionNameKeyPath: nil, cacheName: nil)

        let billItemsObservable: Observable<[BillItem]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(billItemsFRC)

        let frc = Basket.fetchResultsControllerFor(id: basketId)

        let basketInCD: Observable<[Basket]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc).shareReplayLatestWhileConnected()

        let basketAndBillItemsInCD = Observable.combineLatest(billItemsObservable, basketInCD, resultSelector: {
            return $0.1
        })

        let refreshedBasket = viewWillAppear.flatMapLatest {
            return basketService.refreshBasketWith(id: basketId)
        }

        let a = basketAndBillItemsInCD
            .mapAndFilterNil { $0.first }
            .map { CachedItemsResult.success(item: $0!) }

        let b = refreshedBasket
            .map { CachedItemsResult.success(item: $0) }
            .startWith(CachedItemsResult.loading)

        let c = Observable.of(a, b).merge()

        self.basket = c.asDriver(onErrorJustReturn: .error)

        self.billItems = self.basket.map({
            result -> CachedItemsResult<[BillItem]> in
            switch result {
            case .error:
                return .error
            case .loading:
                return .loading
            case .success(let basket):
                let items = basket.bill?.billItems?.allObjects as? [BillItem] ?? []
                return CachedItemsResult.success(item: items.sorted { $0.isOrderedBefore($1, withCurrentUserId: userId) } )
            }
        })
    }

}
