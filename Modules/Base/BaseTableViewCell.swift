//
//  BaseTableViewCell.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseTableViewCell: UITableViewCell {
    var rxReused: Observable<Void> {
        return self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in return () }
    }
}
