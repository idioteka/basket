//
//  RoundedButton.swift
//  Basket
//
//  Created by Mario Radonic on 4/30/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = rect.height/2
        clipsToBounds = true
    }

}
