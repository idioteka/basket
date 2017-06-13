//
//  Recommendation.swift
//  Basket
//
//  Created by Mario Radonic on 23/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData


class Recommendation: NSManagedObject {

    class func createWith(_ jsonDictionary: JSONDictionary) throws -> Recommendation {
        guard
            let name = jsonDictionary["name"] as? String,
            let url = jsonDictionary["url"] as? String
        else {
                print("Error creating recommendation from json ")
                print(jsonDictionary)
                throw APIError.errorParsingJSON
        }
        
        let recommendation = Recommendation.firstOrCreate(with: ["name": name])
        
        recommendation.name = name
        recommendation.url = url
        
        return recommendation
    }
}
