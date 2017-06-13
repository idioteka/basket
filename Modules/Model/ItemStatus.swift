//
//  ItemStatus.swift
//  Basket
//
//  Created by Mario Radonic on 12/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

enum ItemStatus: Int {
    case fresh = 1
    case reserved = 2
    case bought = 3
    case deleted = 4
    
    var statusImageName: String {
        switch self {
        case .fresh:
            return "itemStatusFresh"
        case .reserved:
            return "itemStatusReserved"
        case .bought:
            return "itemStatusBought"
        case .deleted:
            return ""
        }
    }
}
