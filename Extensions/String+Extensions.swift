//
//  String+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 4/17/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

extension String {
    func toEmoji() -> String? {
        if let a = Int(self, radix: 16) {
            return String(Character(UnicodeScalar(a)!))
        }
        return nil
    }
}
