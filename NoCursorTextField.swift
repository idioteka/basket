//
//  NoCursorTextField.swift
//  Basket
//
//  Created by Mario Radonic on 5/22/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class NoCursorTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
