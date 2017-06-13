//
//  Basket.swift
//  Basket
//
//  Created by Mario Radonic on 4/9/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import AERecord

class Basket: NSManagedObject {


    var dueDate: Date? {
        guard dueDateInterval != 0 else {
            return nil
        }
        return DateUtil.dateFromTimeInterval(dueDateInterval)
    }

    func belongsToUserWith(id: Int) -> Bool {
        return Int(owner?.id ?? 0) == id
    }

    var basketSummary: String {
        var summary = ""
        if let dueDate = dueDate?.naturalReferenceString {
           summary += "\(dueDate), "
        }
        summary += "\((basketeerCount)) people"
        return summary
    }

    static func createWith(_ json: JSONDictionary, pending: Bool) throws -> Basket {
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let isLocked = json["is_locked"] as? Bool,
            let icon = json["icon"] as? String,
            let createdAt = json["created_at"] as? String,
            let updatedAt = json["updated_at"] as? String,
            let isArchived = json["is_archived"] as? Bool,
            let basketeer_count = json["basketeer_count"] as? Int,
            let ownerJson = json["owner"] as? JSONDictionary,
            let owner = try? User.createWith(jsonDictionary: ownerJson),
            let itemsCount = json["items_count"] as? Int
        else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }

        let basket = Basket.firstOrCreate(with: "id", value: id)
        basket.pending = pending

        basket.name = name
        basket.basketDescription = json["description"] as? String ?? ""
        basket.detailString = json["detail_string"] as? String ?? ""
        basket.isLocked = isLocked
        basket.icon = icon
        basket.createdAtInterval = DateUtil.timeIntervalFromStringOrNonValue(createdAt) ?? 0
        basket.updatedAtInterval = DateUtil.timeIntervalFromStringOrNonValue(updatedAt) ?? 0
        if let dueDate = json["due_date"] as? String {
            basket.dueDateInterval = DateUtil.timeIntervalFromStringOrNonValue(dueDate) ?? 0
        }
        basket.isArchived = isArchived
        basket.basketeerCount = Int16(basketeer_count)
        basket.owner = owner
        basket.itemCount = Int16(itemsCount)

        if let inviteId = json["invite_id"] as? Int {
            basket.inviteId = Int16(inviteId)
        }

        if
            let invitedByJSON = json["invited_by"] as? JSONDictionary,
            let invitedBy = try? User.createWith(jsonDictionary: invitedByJSON) {
                basket.invitedBy = invitedBy
        }

        return basket
    }

    static func fetchResultsControllerFor(id: Int) -> NSFetchedResultsController<Basket> {
        let fetchRequest: NSFetchRequest<Basket> = Basket.createFetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)

        let frc: NSFetchedResultsController<Basket> = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: AERecord.Context.default,
            sectionNameKeyPath: nil, cacheName: nil
        )

        return frc
    }

    func setNewBill(_ bill: Bill) {
        if let bill = self.bill {
            bill.delete()
        }
        self.bill = bill
    }

}

