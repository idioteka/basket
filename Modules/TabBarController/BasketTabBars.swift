//
//  BasketTabBars.swift
//  Basket
//
//  Created by Mario Radonic on 12/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

enum BasketTabBars {
    case items
    case people
    case details
    case splitBill
    case activity
    
    var title: String {
        switch self {
        case .items:
            return "Items"
        case .people:
            return "People"
        case .splitBill:
            return "Split the Bill"
        case .details:
            return "Details"
        case .activity:
            return "Activity"
        }
    }
    
    var imageName: String {
        switch self {
        case .items:
            return "iconItems"
        case .people:
            return "iconPeople"
        case .splitBill:
            return "iconCreditCard"
        case .details:
            return "iconBasket"
        case .activity:
            return "iconActivity"
        }
    }
    
    var selectedImageName: String {
        switch self {
        case .items:
            return "iconItemsActive"
        case .people:
            return "iconPeopleActive"
        case .splitBill:
            return "iconCreditCardActive"
        case .details:
            return "iconBasketActive"
        case .activity:
            return "iconActivityActive"
        }
    }
}
