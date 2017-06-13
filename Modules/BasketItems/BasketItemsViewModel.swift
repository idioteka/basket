//
//  ItemsViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 28/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import CoreData
import AERecord

class BasketItemsViewModel {

    let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService

    fileprivate let basketId: Int
    fileprivate let userId: Int

    let basket: Driver<CachedItemsResult<Basket>>
    let clearNewItemField: Driver<Void>

    let itemCellViewModels: Driver<CachedItemsResult<[ItemCellViewModel]>>
    let hideEmptyScreen: Driver<Bool>
    let hideAddItem: Driver<Bool>
    let refresh = PublishSubject<Void>()
    let refreshing: Driver<Bool>

    init(basketService: BasketService,
         basketId: Int, userId: Int,
         itemAction: Observable<(BasketItemAction, Int)>,
         addItem: Driver<String>)
    {
        self.userId = userId
        self.basketService = basketService
        self.basketId = basketId

        let itemsFR: NSFetchRequest<BasketItem> = BasketItem.createFetchRequest()
        itemsFR.sortDescriptors = []

        let itemsFRC: NSFetchedResultsController<BasketItem> = NSFetchedResultsController(fetchRequest: itemsFR, managedObjectContext: AERecord.Context.default, sectionNameKeyPath: nil, cacheName: nil)

        let itemsObservable: Observable<[BasketItem]>  = AERecord.Context.default.rx_entitiesForFetchedResultsController(itemsFRC)

        let frc = Basket.fetchResultsControllerFor(id: basketId)

        let basketInCD: Observable<[Basket]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc).shareReplayLatestWhileConnected()
        let basketAndItemsInCD = Observable.combineLatest(itemsObservable, basketInCD, resultSelector: { return $0.1 })

        let refreshedBasket = refresh.asObservable().startWith().flatMapFirst { _ -> Observable<CachedItemsResult<Basket>> in
            return basketService.refreshBasketWith(id: basketId)
                .map { CachedItemsResult.success(item: $0) }
                .startWith(CachedItemsResult.loading)
        }

        let a = basketAndItemsInCD.mapAndFilterNil { $0.first }.map { CachedItemsResult.success(item: $0!) }

        let c = Observable.of(a, refreshedBasket).merge().shareReplayLatestWhileConnected()

        self.refreshing = c.map { $0.isRefreshing() }
            .asDriver(onErrorJustReturn: false)

        self.basket = c.asDriver(onErrorJustReturn: .error)

        addItem.drive(onNext: { itemName in
            basketService.createItemWithName(name: itemName, inBasketWithId: basketId)
        }).addDisposableTo(disposeBag)

        self.itemCellViewModels = self.basket.map({
            result -> CachedItemsResult<[ItemCellViewModel]> in
            switch result {
            case .error:
                return .error
            case .loading:
                return .loading
            case .success(let basket):
                let items = basket.basketDetails?.items?.allObjects as? [BasketItem] ?? []
                return CachedItemsResult.success(item: items.sorted { $0.isOrderedBefore($1) } .filter{ Int($0.statusId) != ItemStatus.deleted.rawValue }.map({ ItemCellViewModel(basketService: basketService, itemId: Int($0.id), userId: userId) }))
            }
        })

        itemAction.subscribe(onNext: { (action, id) in
            basketService.updateItemWithAction(action: action, forItemId: id, userId: userId)
        }).addDisposableTo(disposeBag)

        self.clearNewItemField = addItem.map { _ in () }

        self.hideEmptyScreen = self.basket.map({
            result -> Bool in
            switch result {
            case .error:
                return false
            case .loading:
                return true
            case .success(let basket):
                let items = basket.basketDetails?.items?.allObjects as? [BasketItem] ?? []
                return !items.isEmpty
            }
        })

        self.hideAddItem = self.basket.map({
            result -> Bool in
            switch result {
            case .error:
                return true
            case .loading:
                return false
            case .success(let basket):
                if !basket.isLocked {
                    return false
                } else if basket.belongsToUserWith(id: userId) {
                    return false
                }
                return true
            }
        })
    }
}
