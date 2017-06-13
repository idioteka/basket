//
//  UITableView+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

extension UITableView {
    func registerCellWithSameNamedNib(_ cellType: UITableViewCell.Type) {
        register(cellType.sameNamedNib, forCellReuseIdentifier: cellType.className)
    }
}
