//
//  NSObject+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 2/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        var name = NSStringFromClass(self)
        name = name.components(separatedBy: ".").last ?? ""
        return name
    }
}
