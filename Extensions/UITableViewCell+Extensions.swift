//
//  UITableViewCell+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var sameNamedNib: UINib? {
        return UINib(nibName: className, bundle: nil)
    }
}
