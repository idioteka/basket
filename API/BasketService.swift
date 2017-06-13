//
//  BasketService.swift
//  Basket
//
//  Created by Mario Radonic on 4/2/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import AERecord

class BasketService {
    let networking: AuthorizedNetworking

    let disposeBag = DisposeBag()

    init(networking: AuthorizedNetworking) {
        self.networking = networking
    }

    func refreshBaskets() -> Observable<CachedItemsResult<[Basket]>> {
        return networking.provider
            .request(BasketAuthenticatedAPI.baskets)
            .map { try $0.mapJSONDictionry() }
            .map { self.parseAndCreateBasketsFrom(json: $0) }
            .map { CachedItemsResult.success(item: $0) }
            .do(onNext: { _ in
                try! AERecord.Context.default.save()
            })
            .catchError({ (error) -> Observable<CachedItemsResult<[Basket]>> in
                return Observable.just(CachedItemsResult.error)
            }).shareReplay(1)
    }

    func refreshBasketWith(id basketId: Int) -> Observable<Basket> {
        return networking.provider
            .request(BasketAuthenticatedAPI.basketDetails(basketId))
            .map { try $0.mapJSONDictionry() }
            .map { try self.parseBasketDetailsResponse(json: $0) }
            .map { details -> Basket in
                guard let basket = Basket.first(with: "id", value: basketId) else {
                    throw NSError(domain: "", code: 0, userInfo: nil) // TODO:
                }
                basket.basketDetails = details

                try AERecord.Context.default.save()

                return basket
            }
    }

    func refreshBillWithBasketId(basketId: Int) -> Observable<Basket> {
        return networking.provider
            .request(BasketAuthenticatedAPI.splitBill(basketId))
            .map { try $0.mapJSONDictionry() }
            .map { try self.parseSplitBillResponse(json: $0) }
            .map({ (bill) -> Basket in
                guard let basket = Basket.first(with: "id", value: basketId) else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
                basket.setNewBill(bill)
                try AERecord.Context.default.save()
                return basket
            })
    }

    func refreshBasketActivity(basketId: Int) -> Observable<Basket> {
        let token = BasketAuthenticatedAPI.activity(basketId)

        return networking.provider.request(token).map({ (response) in
            try response.filterSuccessfulStatusCodes()
        }).map {
            try $0.mapJSONDictionry()
            }.map {
                try self.parseActivityResponse(json: $0)
            }.map { (basketActivities) in
                guard let basket = Basket.first(with: "id", value: basketId) else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
                if let activities = basket.basketDetails?.activities?.allObjects {
                    let oldActivities = NSMutableSet(array: activities)
                    let newActivities = NSSet(array: basketActivities)
                    oldActivities.union(newActivities as Set<NSObject>)
                    basket.basketDetails?.activities = oldActivities
                } else {
                    basket.basketDetails?.activities = NSSet(array: basketActivities)
                }
                try AERecord.Context.default.save()
                return basket
        }
    }

    func updateItemWithAction(action: BasketItemAction, forItemId itemId: Int, userId: Int) {
        guard
            let item = BasketItem.first(with: "id", value: itemId),
            let basketIdRaw = item.basketDetails?.basket?.id else {
                return
        }

        let basketId = Int(basketIdRaw)

        let previousName = item.name
        let previousPrice = item.price
        let previousStatusId = item.statusId
        let previousActionedBy = item.actionedBy

        switch action {
        case .unreserve:
            item.actionedBy = nil
            if let statusId = action.status?.rawValue {
                item.statusId = Int16(statusId)
            }
        case .reserve, .delete:
            if let statusId = action.status?.rawValue {
                item.statusId = Int16(statusId)
            }
            item.actionedBy = User.getWithId(userId)
        case .edit(let name):
            item.name = name
        case .buy(let price):
            item.price = NSDecimalNumber(value: (price ?? 0))
            if let statusId = action.status?.rawValue {
                item.statusId = Int16(statusId)
            }
            item.actionedBy = User.getWithId(userId)
        }

        let token = BasketAuthenticatedAPI.itemAction(action: action, basketId: basketId, itemId: itemId)

        networking.provider.request(token).map { (response) in
            try response.filterSuccessfulStatusCodes()
        }.subscribe(onError: { error in
            item.name = previousName
            item.price = previousPrice
            item.statusId = previousStatusId
            item.actionedBy = previousActionedBy
        }).addDisposableTo(disposeBag)
    }

    func createItemWithName(name: String, inBasketWithId basketId: Int) {
        guard let basket = Basket.first(with: "id", value: basketId) else {
            return
        }

        let token = BasketAuthenticatedAPI.createItem(basketId: basketId, itemName: name)

        let basketItemObservable = networking.provider.request(token).map { (response) in
            try response.filterSuccessfulStatusCodes()
        }.map {
            try $0.mapJSONDictionry()
        }.map {
           try self.parseItemResponse(json: $0)
        }.shareReplayLatestWhileConnected()

        basketItemObservable.subscribe(onNext :{ (basketItem) in
            basketItem.basketDetails = basket.basketDetails
            _ = try? AERecord.Context.default.save()
        }).addDisposableTo(disposeBag)

        basketItemObservable.subscribe(onError: { (error) in
            // TODO: handleError
        }).addDisposableTo(disposeBag)
    }

    func inviteUserWithId(userId: Int, toBasketWithId basketId: Int) -> Observable<Void> {
        let token = BasketAuthenticatedAPI.addUserToBasket(userId: userId, basketId: basketId)
        return networking.provider.request(token).filterSuccessfulStatusCodes().mapVoid()
    }

    func sendInvitationAction(action: BasketInvitationAction, forBasketWithId basketId: Int) {
        guard let basket = Basket.first(with: "id", value: basketId) else {
            return
        }
        let inviteId = Int(basket.inviteId)

        let token = BasketAuthenticatedAPI.invitationAction(
            action: action,
            basketId: basketId,
            inviteId: inviteId
        )

        networking.provider.request(token).map { (response) in
            _ = try response.filterSuccessfulStatusCodes()
            switch action {
            case .accept:
                basket.pending = false
            case .reject, .rejectAndBlock:
                basket.delete(from: AERecord.Context.default)
            }
            try AERecord.Context.default.save()
        }.subscribe(onNext: {
            print("Success")
        }).addDisposableTo(disposeBag)
    }

    func leaveBasket(basketId: Int, userId: Int) -> Observable<()> {
        guard let basket = Basket.first(with: "id", value: basketId) else {
            return Observable.error(NSError(domain: "TODO", code: 0, userInfo: nil))
        }

        if let ownerId = basket.owner?.id, Int(ownerId) == userId {
            return archiveBasket(basket: basket)
        }

        let token = BasketAuthenticatedAPI.leaveBasket(basketId: basketId, userId: userId)

        return networking.provider.request(token).map { (response) in
            _ = try response.filterSuccessfulStatusCodes()
            AERecord.Context.default.delete(basket)
            try AERecord.Context.default.save()
        }.shareReplayLatestWhileConnected()
    }

    func archiveBasket(basket: Basket) -> Observable<()> {
        let token = BasketAuthenticatedAPI.archiveBasket(Int(basket.id))

        return networking.provider.request(token).map { response in
            _ = try response.filterSuccessfulStatusCodes()
            basket.isArchived = true
            try AERecord.Context.default.save()
        }.shareReplayLatestWhileConnected()
    }

    private func parseAndCreateBasketsFrom(json: JSONDictionary) -> [Basket] {
        var baskets = [Basket]()

        if let basketsJSON = json["baskets"] as? [JSONDictionary] {
            baskets.append(
                contentsOf: basketsJSON.flatMap { try? Basket.createWith($0, pending: false) }
            )
        }

        if let basketsJSON = json["pending"] as? [JSONDictionary] {
            baskets.append(
                contentsOf: basketsJSON.flatMap { try? Basket.createWith($0, pending: true) }
            )
        }

        return baskets
    }

    private func parseBasketDetailsResponse(json: JSONDictionary) throws -> BasketDetails {

        let details = try BasketDetails.createWith(json)

        return details
    }

    private func parseItemResponse(json: JSONDictionary) throws -> BasketItem {
        let item = try BasketItem.createWith(json)
        return item
    }

    private func parseActivityResponse(json: JSONDictionary) throws -> [BasketActivity] {
        var activities = [BasketActivity]()
        if let activitiesJSON = json["activities"] as? JSONArray {
            for activityJSON in activitiesJSON {
                let activity = try BasketActivity.createWith(activityJSON)
                activities.append(activity)
            }
        }
        return activities
    }

    private func parseSplitBillResponse(json: JSONDictionary) throws -> Bill {
        let bill = try Bill.createWith(json)
        return bill
    }

    func fetchNotDeletedItemsForSelectedBasket(basketId: String) -> [BasketItem]? {
        return nil
    }
}
