//
//  BillItem+CoreDataProperties.swift
//  Basket
//
//  Created by Mario Radonic on 30/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BillItem {

    @NSManaged var amount: Double
    @NSManaged var person: User?
    @NSManaged var bill: Bill?

}
