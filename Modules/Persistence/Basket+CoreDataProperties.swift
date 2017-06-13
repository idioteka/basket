//
//  Basket+CoreDataProperties.swift
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

extension Basket {

    @NSManaged var basketDescription: String?
    @NSManaged var basketeerCount: Int16
    @NSManaged var createdAtInterval: TimeInterval
    @NSManaged var detailString: String
    @NSManaged var dueDateInterval: TimeInterval
    @NSManaged var icon: String?
    @NSManaged var id: Int32
    @NSManaged var inviteId: Int16
    @NSManaged var isArchived: Bool
    @NSManaged var isLocked: Bool
    @NSManaged var itemCount: Int16
    @NSManaged var name: String?
    @NSManaged var pending: Bool
    @NSManaged var updatedAtInterval: TimeInterval
    @NSManaged var basketDetails: BasketDetails?
    @NSManaged var bill: Bill?
    @NSManaged var invitedBy: User?
    @NSManaged var owner: User?

}
