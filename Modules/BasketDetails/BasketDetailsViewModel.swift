//
//  BasketDetailsViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 12/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import AERecord
import MapKit

class BasketDetailsViewModel {

    let disposeBag = DisposeBag()
    fileprivate let basketService: BasketService
    let basketId: Int
    let userId: Int

    let icon: Driver<String>
    let isLocked: Driver<Bool>
    let isMuted: Driver<Bool>
    let title: Driver<String>
    let dueDate: Driver<String>
    let description: Driver<String>
    let location: Driver<(longitude: Double, latitude: Double)?>
    let address: Driver<String>
    let leaveBasketText: Driver<String>

    let userLeftBasket: Driver<Bool>

    var coordinates: (longitude: Double, latitude: Double)?
    var addressString: String?

    init(basketService: BasketService, basketId: Int, userId: Int, leaveBasket: Observable<()>) {
        self.basketService = basketService
        self.basketId = basketId
        self.userId = userId

        let frc = Basket.fetchResultsControllerFor(id: basketId)

        self.coordinates = nil
        addressString = nil

        if let basketObject = Basket.first(with: NSPredicate(format: "id = %d", basketId)) {
            if
                let longitude = basketObject.basketDetails?.location?.longitude,
                let longitudeDouble = Double(longitude),
                let latitude = basketObject.basketDetails?.location?.latitude,
                let latitudeDouble = Double(latitude) {
                    self.coordinates = (longitudeDouble, latitudeDouble)
            }
            if let address = basketObject.basketDetails?.location?.address {
                addressString = address
            }
        }

        let basketInCD: Observable<[Basket]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc).shareReplayLatestWhileConnected()

        let refreshedBasket = basketService.refreshBasketWith(id: basketId)

        let a = basketInCD
            .mapAndFilterNil { $0.first }
            .map { CachedItemsResult.success(item: $0) }

        let b = refreshedBasket
            .map { CachedItemsResult.success(item: $0) }
            .startWith(CachedItemsResult.loading)

        let c = Observable.of(a,b).merge().shareReplayLatestWhileConnected()

        let basket = c.asDriver(onErrorJustReturn: .error)

        self.icon = basket.map({ (result) -> String in
            switch result {
            case .success(let basket):
                return basket.icon?.toEmoji() ?? ""
            default:
                return ""
            }
        })

        self.title = basket.map({ (result) -> String in
            switch result {
            case .success(let basket):
                return basket.name ?? ""
            default:
                return ""
            }
        })

        self.dueDate = basket.map({ (result) -> String in
            switch result {
            case .success(let basket):
                return basket.dueDate?.naturalReferenceString ?? ""
            default:
                return ""
            }
        })

        self.description = basket.map({ (result) -> String in
            switch result {
            case .success(let basket):
                return basket.basketDescription ?? ""
            default:
                return ""
            }
        })

        self.location = basket.map({ (result) -> (longitude: Double, latitidue: Double)? in
            switch result {
            case .success(let basket):
                if
                    let longitude = basket.basketDetails?.location?.longitude,
                    let longitudeDouble = Double(longitude),
                    let latitude = basket.basketDetails?.location?.latitude,
                    let latitudeDouble = Double(latitude) {
                        return (longitudeDouble, latitudeDouble)
                } else {
                    return nil
                }
            default:
                return nil
            }
        })

        self.address = basket.map({ (result) -> String in
            switch result {
            case .success(let basket):
                return basket.basketDetails?.location?.address ?? ""
            default:
                return ""
            }
        })

        self.isLocked = basket.map({ (result) -> Bool in
            switch result {
            case .success(let basket):
                return basket.isLocked
            default:
                return false
            }
        })

        self.isMuted = basket.map { result -> Bool in
            switch result {
            case .success(let basket):
                return basket.basketDetails?.isMuted ?? false
            default:
                return false
            }
        }

        self.leaveBasketText = basket.map { result -> String in
            switch result {
            case .success(let basket):
                if let ownerId = basket.owner?.id , Int(ownerId) == userId {
                    return "Archive basket"
                }
                return "Leave this basket"
            default:
                return ""
            }
        }

        self.userLeftBasket = leaveBasket.flatMapLatest { () -> Observable<Bool> in
            return basketService.leaveBasket(basketId: basketId, userId: userId).map { true }
        }.asDriver(onErrorJustReturn: false)
    }
}
