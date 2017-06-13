//
//  Recommendation+CoreDataProperties.swift
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

extension Recommendation {

    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var items: BasketItem?

}
