//
//  Authentication.swift
//  Basket
//
//  Created by Mario Radonic on 2/12/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

struct LoginDetails {
    let email: String
    let password: String

    static var empty: LoginDetails {
        return LoginDetails(email: "", password: "")
    }

    func toJSONDictionary() -> JSONDictionary {
        return [
            "email": email as AnyObject,
            "password": password as AnyObject
        ]
    }
}

struct UserSignupDetails {
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var avatar: UIImage?

    func toJSONDictionary() -> JSONDictionary {
        let required = [
            APIConstant.Key.firstName: self.firstName,
            APIConstant.Key.lastName: self.lastName,
            APIConstant.Key.email: self.email,
            APIConstant.Key.password: self.password
        ]
        if avatar != nil {
            fatalError("Not yet implemented")
        }
        return required as JSONDictionary
    }

    static var empty: UserSignupDetails {
        return UserSignupDetails(firstName: "", lastName: "", email: "", password: "", avatar: nil)
    }

    var valid: Bool {
        // TODO:
        return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && password.characters.count > 4
    }
}
