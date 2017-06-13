//
//  BasketItemsAction.swift
//  Basket
//
//  Created by Mario Radonic on 16/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

enum BasketItemAction {
    case edit(String), delete, reserve, buy(Double?), unreserve
    
    var title: String {
        switch self {
        case .edit:
            return "EDIT"
        case .reserve:
            return "RESERVE"
        case .delete:
            return "DELETE"
        case .buy:
            return "BUY"
        case .unreserve:
            return "UNRESERVE"
        }
    }
    
    var status: ItemStatus? {
        switch self {
        case .unreserve:
            return .fresh
        case .reserve:
            return .reserved
        case .buy:
            return .bought
        case .delete:
            return .deleted
        case .edit:
            return nil
        }
    }
    
    var iconName: String {
        switch self {
        case .edit:
            return "itemActionEdit"
        case .reserve:
            return "itemActionReserve"
        case .delete:
            return "itemActionDelete"
        case .buy:
            return "itemActionBuy"
        case .unreserve:
            return "itemActionReserve"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .edit:
            return UIColor.bsktBlueGreyColor()
        case .reserve:
            return UIColor.bsktSalmonColor()
        case .delete:
            return UIColor.bsktCoralColor()
        case .buy:
            return UIColor.bsktAlgaeGreenColor()
        case .unreserve:
            return UIColor.bsktSalmonColor()
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .delete:
            return ["status": 4 as AnyObject]
        case .edit(let name):
            return ["name": name as AnyObject]
        case .buy(let price):
            return [
                "price": price as AnyObject? ?? 0 as AnyObject,
                "status": 3 as AnyObject
            ]
        case .reserve:
            return ["status": 2 as AnyObject]
        case .unreserve:
            return ["status": 1 as AnyObject]
        }
    }

    var isEdit: Bool {
        switch self {
        case .edit: return true
        default: return false
        }
    }
    
    var isBuy: Bool {
        switch self {
        case .buy: return true
        default: return false
        }
    }
}
