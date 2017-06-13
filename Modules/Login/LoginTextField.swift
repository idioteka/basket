//
//  TextFieldWithInset.swift
//  Basket
//
//  Created by Mario Radonic on 09/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDesign()
    }

    func setupDesign() {
        borderStyle = .none
        font = UIFont.bsktBigMediumFont()
    }

    func setCustomPlaceholder(_ placeholder: String) {
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSForegroundColorAttributeName: UIColor.bsktGreyishTwoColor(),
            NSFontAttributeName: UIFont.bsktBigMediumFont()
        ])
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15, dy: 0)
    }
}
