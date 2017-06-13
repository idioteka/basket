//
//  AddMorePeopleCell.swift
//  Basket
//
//  Created by Mario Radonic on 4/24/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift

class AddMorePeopleCell: UITableViewCell {

    var disposeBag = DisposeBag()

    @IBOutlet weak var queryTextField: UITextField!

    let borderColor = UIColor.bsktWhiteTwoColor()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        queryTextField.font = UIFont.bsktBigMediumFont()
        queryTextField.attributedPlaceholder = NSAttributedString(
            string: "Invite people by name or email address",
            attributes: [
                NSFontAttributeName: UIFont.bsktBigMediumFont(),
                NSForegroundColorAttributeName: UIColor.bsktGreyishTwoColor()
            ]
        )

        let topBorder = rect.topBorderLine
        borderColor.setStroke()
        topBorder.stroke()

        borderColor.setStroke()
        rect.bottomBorderLine.stroke()
    }
}
