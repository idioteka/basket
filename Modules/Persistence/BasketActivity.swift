//
//  BasketActivity.swift
//  Basket
//
//  Created by Mario Radonic on 01/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources

class BasketActivity: NSManagedObject {

    class func createWith(_ json: JSONDictionary) throws -> BasketActivity {
        guard
            let id = json["id"] as? Int,
            let message = json["message"] as? String,
            let icon = json["icon"] as? String,
            let pretyTime = json["pretty_time_ago"] as? String,
            let createdAt = json["created_at"] as? String else {
                throw APIError.errorParsingJSON
        }
        
        let activity = BasketActivity.firstOrCreate(with: ["id": id])
        activity.message = message
        activity.icon = icon
        activity.pretyTime = pretyTime
        activity.createdAt = DateUtil.timeIntervalFromStringOrNonValue(createdAt) ?? 0
        return activity
    }
}

extension BasketActivity: IdentifiableType {
    var identity: Int {
        return Int(self.id)
    }
}
