//
//  SignupInputFields.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift

enum SignupInputField {
    case firstName
    case lastName
    case email
    case password

    static var allEmpty: [SignupInputField] {
        return [
            .firstName,
            .lastName,
            .email,
            .password
        ]
    }
}
