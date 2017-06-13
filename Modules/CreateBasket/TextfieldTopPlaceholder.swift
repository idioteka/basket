//
//  TextfieldTopPlaceholder.swift
//  Basket
//
//  Created by Mario Radonic on 5/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class TextfieldTopPlaceholder: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        textColor = UIColor.bsktWarmGreyTwoColor()
        font = UIFont.bsktMediumBoldFont()
    }
}

class CreateBasketTitleLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.bsktBigMediumFont()
        textColor = UIColor.bsktGreyishBrownColor()
    }
}

class CreateBasketDescriptionLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.bsktSmallishRegularFont()
        textColor = UIColor.bsktWarmGreyColor()
    }
}

class CreateBasketTextField: NoCursorTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.bsktBiggerRegularFont()
        textColor = UIColor.bsktWarmGreyTwoColor()
    }
}
