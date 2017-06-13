//
//  BasketActivity+CoreDataProperties.swift
//  Basket
//
//  Created by Mario Radonic on 01/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BasketActivity {

    @NSManaged var message: String?
    @NSManaged var id: Int32
    @NSManaged var icon: String?
    @NSManaged var createdAt: TimeInterval
    @NSManaged var pretyTime: String?
    @NSManaged var basketDetails: BasketDetails?

}
