//
//  Location.swift
//  Basket
//
//  Created by Mario Radonic on 01/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    class func createWith(_ json: JSONDictionary) throws -> Location {
        guard
            let address = json["address"] as? String,
            let latitude = json["latitude"] as? String,
            let longitude = json["longitude"] as? String,
            let map = json["map"] as? String else {
                throw APIError.errorParsingJSON
        }
        
        let location = Location.create()
        location.address = address
        location.map = map
        location.longitude = longitude
        location.latitude = latitude
        return location
    }
}
