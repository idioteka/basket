//
//  ItemCellViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 17/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import RxOptional
import RxDataSources
import CoreData
import AERecord

class ItemCellViewModel {

    let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService

    let itemId: Int
    fileprivate let userId: Int

    let item: Driver<CachedItemsResult<BasketItem>>

    fileprivate var successItem: Driver<BasketItem> {
        return item.map { (result) -> BasketItem? in
            switch result {
            case .success(let item):
                return item
            default:
                return nil
            }
        }.filterNil()
    }

    var title: Driver<String> {
        return successItem.map { $0.name ?? "" }
    }

    var price: Driver<String> {
        return successItem.map { item -> String in
            return (item.price != nil) ? "\(item.price!) HRK" : ""
        }
    }

    var recommendationText: Driver<String?> {
        return successItem.map { item -> String? in
            return item.recommendation?.name
        }
    }

    var statusImage: Driver<UIImage?> {
        return successItem.map { item -> UIImage? in
            if
                let status = ItemStatus(rawValue: Int(item.statusId)),
                let image = UIImage(named: status.statusImageName) {
                    return image
            }
            return nil
        }
    }

    var actionedByAvatar: Driver<URL?> {
        return successItem.map { item -> URL? in
            if let avatarUrl = item.actionedBy?.avatar, let avatar = URL(string: avatarUrl) {
                return avatar
            }
            return nil
        }
    }

    var leftButtons: Driver<[BasketItemAction]> {
        return successItem.map { item ->  [BasketItemAction] in
            guard
                let itemStatus = ItemStatus(rawValue: Int(item.statusId)),
                let basketLocked = item.basketDetails?.basket?.isLocked,
                let isUserOwner = item.basketDetails?.basket?.belongsToUserWith(id: self.userId) else {
                return []
            }
            let isActionedByUser = item.isActionedByUserWith(id: self.userId)
            switch itemStatus {
            case .fresh:
                return (isUserOwner || !basketLocked) ? [.edit(item.name ?? ""), .delete] : []
            case .reserved:
                return isActionedByUser ? [.edit(item.name ?? ""), .delete] : []
            case .bought, .deleted:
                return []
            }
        }
    }

    var rightButtons: Driver<[BasketItemAction]> {
        return successItem.map { item ->  [BasketItemAction] in
            guard
                let itemStatus = ItemStatus(rawValue: Int(item.statusId)),
                let basketLocked = item.basketDetails?.basket?.isLocked,
                let isUserOwner = item.basketDetails?.basket?.belongsToUserWith(id: self.userId) else {
                    return []
            }
            let isActionedByUser = item.isActionedByUserWith(id: self.userId)
            switch itemStatus {
            case .fresh:
                if !basketLocked || isUserOwner {
                    return [.reserve, .buy(nil), .delete]
                } else {
                    return [.reserve, .buy(nil)]
                }
            case .reserved:
                if isUserOwner && isActionedByUser {
                    return [.unreserve, .buy(nil), .delete]
                } else if isUserOwner {
                    return [.delete]
                } else if isActionedByUser {
                    return [.unreserve, .buy(nil)]
                } else {
                    return []
                }
            case .bought:
                if isUserOwner && isActionedByUser {
                    return [.unreserve, .buy(nil), .delete]
                } else if isUserOwner {
                    return [.delete]
                } else if isActionedByUser {
                    return [.unreserve, .buy(nil)]
                } else {
                    return []
                }
            case .deleted:
                return []
            }
        }
    }

    init(basketService: BasketService, itemId: Int, userId: Int) {
        self.userId = userId
        self.basketService = basketService
        self.itemId = itemId

        let frc = BasketItem.fetchResultsControllerForId(itemId)

        let itemInCD: Observable<[BasketItem]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc)

        let a = itemInCD
            .map { $0.first }.filterNil()
            .map { CachedItemsResult.success(item: $0) }

        self.item = a.asDriver(onErrorJustReturn: .error)
    }

}

extension ItemCellViewModel: IdentifiableType, Hashable {
    var identity : Int { return itemId }
    var hashValue: Int { return itemId }
}

func == (lhs: ItemCellViewModel, rhs: ItemCellViewModel) -> Bool {
    return lhs.itemId == rhs.itemId
}
