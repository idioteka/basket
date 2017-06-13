//
//  Bill.swift
//  Basket
//
//  Created by Mario Radonic on 30/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import AERecord

class Bill: NSManagedObject {
    
    static func createWith(_ json: JSONDictionary) throws -> Bill {
        let bill = Bill.create()
        
        if let people = json["people"] as? JSONArray {
            let array = people.flatMap { try? BillItem.createWith($0) }
            bill.billItems = NSSet(array: array)
        }
        
        guard let
            total = json["total"] as? Double else {
                throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        bill.total = total
        
        return bill
    }
}
