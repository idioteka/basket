//
//  BasketItem.swift
//  Basket
//
//  Created by Mario Radonic on 4/9/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import AERecord

class BasketItem: NSManagedObject {
    
    func isActionedByUserWith(id: Int) -> Bool {
        return Int(actionedBy?.id ?? 0) == id
    }

    static func createWith(_ json: JSONDictionary) throws -> BasketItem {
        guard
            let id = json["id"] as? Int,
            let statusJSON = json["status"] as? JSONDictionary,
            let status = statusJSON["id"] as? Int else {
                throw APIError.errorParsingJSON
        }

        let basketItem = BasketItem.firstOrCreate(with: "id", value: id)

        basketItem.name = json["name"] as? String
        if let price = json["price"] as? Double {
            basketItem.price = NSDecimalNumber(value: price)
        } else {
            basketItem.price = nil
        }
        basketItem.statusId = Int16(status)
        
        if let actionedByJSON = json["actioned_by"] as? JSONDictionary {
            basketItem.actionedBy = User.create(with: actionedByJSON)
        }
        
        if let recommendedJSON = json["recommended"] as? JSONDictionary {
            basketItem.recommendation = Recommendation.create(with: recommendedJSON)
        }
        
        return basketItem
    }
    
    static func fetchResultsControllerForId(_ id: Int) -> NSFetchedResultsController<BasketItem> {
        let fetchRequest: NSFetchRequest<BasketItem> = BasketItem.createFetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: AERecord.Context.default,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        return frc
    }
    
    func isOrderedBefore(_ otherItem: BasketItem) -> Bool {
        if statusId != otherItem.statusId {
            return statusId < otherItem.statusId
        } else {
            return id > otherItem.id
        }
    }

}
