//
//  BasketItem+CoreDataProperties.swift
//  Basket
//
//  Created by Mario Radonic on 23/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BasketItem {

    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var price: NSDecimalNumber?
    @NSManaged var statusId: Int16
    @NSManaged var actionedBy: User?
    @NSManaged var basketDetails: BasketDetails?
    @NSManaged var recommendation: Recommendation?

}
