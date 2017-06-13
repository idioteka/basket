//
//  BasketDetails.swift
//  Basket
//
//  Created by Mario Radonic on 4/9/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import AERecord

class BasketDetails: NSManagedObject {

    var allUsers: [User] {
        return acceptedUsers + pendingUsers
    }

    var pendingUsers: [User] {
        get { return (pendingUsersSet?.allObjects as? [User]) ?? [] }
        set { pendingUsersSet = NSSet(array: newValue) }
    }

    var acceptedUsers: [User] {
        get { return (acceptedUsersSet?.allObjects as? [User]) ?? [] }
        set { acceptedUsersSet = NSSet(array: newValue) }
    }

    static func createWith(_ json: JSONDictionary) throws -> BasketDetails {
        let details = BasketDetails.create()
        
        guard let
            isMuted = json["is_muted"] as? Bool else {
                throw NSError(domain: "", code: 0, userInfo: nil)
        }

        details.isMuted = isMuted

        if let items = json["items"] as? JSONArray {
            let array = items.flatMap { try? BasketItem.createWith($0) }
            details.items = NSSet(array: array)
        }

        if let acceptedUsers = json["people"] as? JSONArray {
            details.acceptedUsers = acceptedUsers.flatMap { try? User.createWith(jsonDictionary: $0) }
        }

        if let pendingUsers = json["invited"] as? JSONArray {
            details.pendingUsers = pendingUsers.flatMap { try? User.createWith(jsonDictionary: $0) }
        }
        
        if let locationJSON = json["location"] as? JSONDictionary {
            details.location = try? Location.createWith(locationJSON)
        }

        return details
    }

    static func createWithItems(_ json: [JSONDictionary]) throws -> BasketDetails {

        let basketDetails = BasketDetails.create()
        basketDetails.items = NSSet()

        for itemJSON in json {
            let basketItem = try BasketItem.createWith(itemJSON)
            basketItem.basketDetails = basketDetails
        }
        
        return basketDetails
    }
}
