//
//  CreateBasketEvent.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreLocation

struct Currency {
    let name: String
    let code: String
    let popular: Bool

    static var defaultCurrency: Currency {
        return Currency(name: "Croatian kuna", code: "HRK", popular: true)
    }

    init(name: String, code: String, popular: Bool) {
        self.name = name
        self.code = code
        self.popular = popular
    }

    init(json: JSONDictionary) throws {
        guard
            let name = json["name"] as? String,
            let code = json["code"] as? String
        else {
            throw NSError(domain: "Currency init", code: -1, userInfo: nil)
        }
        self.name = name
        self.code = code
        self.popular = (json["is_popular"] as? Bool) ?? false
    }
}

func == (lhs: Currency, rhs: Currency) -> Bool {
    return lhs.code == rhs.code
}

struct LocationRaw {
    let address: String
    let coordinates: CLLocationCoordinate2D
}

func == (lhs: LocationRaw, rhs: LocationRaw) -> Bool {
    return lhs.address == rhs.address && rhs.coordinates == lhs.coordinates
}

func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && rhs.longitude == lhs.longitude
}

enum CreateBasketEvent {
    case nameChanged(String)
    case descriptionChanged(String)
    case dueDateChanged(Date?)
    case lockedChanged(Bool)
    case locationChanged(LocationRaw)
    case currencyChanged(Currency)
    case cancelTapped
    case nextTapped
    case resetDateTapped
    case error
}

func == (lhs: CreateBasketEvent, rhs: CreateBasketEvent) -> Bool {
    switch (lhs, rhs) {
    case (.error, .error), (.cancelTapped, .cancelTapped), (.nextTapped, .nextTapped):
        return true
    case (.nameChanged(let lName), .nameChanged(let rName)):
        return lName == rName
    case (.descriptionChanged(let lD), .descriptionChanged(let rD)):
        return lD == rD
    case (.lockedChanged(let lLocked), .lockedChanged(let rLocked)):
        return lLocked == rLocked
    case (.dueDateChanged(let lDate), .dueDateChanged(let rDate)):
        return lDate == rDate
    case (.locationChanged(let lLocation), .locationChanged(let rLocation)):
        return lLocation == rLocation
    case (.currencyChanged(let lCurrency), .currencyChanged(let rCurrency)):
        return lCurrency == rCurrency
    default:
        return false
    }
}
