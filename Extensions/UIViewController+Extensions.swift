//
//  UIViewController+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 2/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

extension UIViewController {
    class func initFromSameNamedNib() -> Self {
        return self.init(nibName: className, bundle: nil)
    }
}
