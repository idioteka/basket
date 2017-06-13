//
//  BillItem.swift
//  Basket
//
//  Created by Mario Radonic on 30/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class BillItem: NSManagedObject {
    
    static func createWith(_ json: JSONDictionary) throws -> BillItem {
        guard let  amount = json["amount"] as? Double else {
            throw APIError.errorParsingJSON
        }
        
        let billItem = BillItem.create()
        
        let user = try! User.createWith(jsonDictionary: json)
        
        billItem.amount = amount
        billItem.person = user
        
        return billItem
    }
    
    func isOrderedBefore(_ otherItem: BillItem, withCurrentUserId userId: Int) -> Bool {
        if let currentPersonId =  otherItem.person?.id , Int(currentPersonId) == userId {
            return false
        }
        return person?.firstName > otherItem.person?.firstName
    }
}

extension BillItem: IdentifiableType {
    var identity: Int {
        return self.hashValue
    }
}
