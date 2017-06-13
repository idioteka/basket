//
//  BasketDetails+CoreDataProperties.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BasketDetails {

    @NSManaged var isMuted: Bool
    @NSManaged var acceptedUsersSet: NSSet?
    @NSManaged var activities: NSSet?
    @NSManaged var basket: Basket?
    @NSManaged var items: NSSet?
    @NSManaged var location: Location?
    @NSManaged var pendingUsersSet: NSSet?

}
