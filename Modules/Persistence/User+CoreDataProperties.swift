//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var avatar: String?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: Int32
    @NSManaged var lastName: String?
    @NSManaged var name: String?
    @NSManaged var acceptedBaskets: NSSet?
    @NSManaged var actionedBaskets: NSSet?
    @NSManaged var invitedBaskets: NSSet?
    @NSManaged var ownedBaskets: NSSet?
    @NSManaged var pendingBaskets: NSSet?
    @NSManaged var billItems: NSSet?

}
