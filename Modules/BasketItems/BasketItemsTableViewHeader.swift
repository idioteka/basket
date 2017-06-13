//
//  BasketItemsTableViewHeader.swift
//  Basket
//
//  Created by Mario Radonic on 24/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BasketItemsTableViewHeader: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addItemTextFieldContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        addItemTextFieldContainer.backgroundColor = UIColor.bsktWhiteColor()
        let font = UIFont.bsktBigBoldFont()
        textField.font = font
        let stringBuilder = AttributedStringBuilder(globalColor: UIColor.bsktGreyishTwoColor(), globalFont: font)
        stringBuilder.appendString("tap to add item")
        textField.attributedPlaceholder = stringBuilder.buildString()
        textField.font = font
        textField.textColor = UIColor.bsktGreyishBrownColor()
    }

    var tap: ControlEvent<Void> {
        let tap = textField.rx.controlEvent(UIControlEvents.editingDidEndOnExit)
        return tap
    }

    var text: ControlProperty<String> {
        return textField.rx.text.orEmpty
    }
}
