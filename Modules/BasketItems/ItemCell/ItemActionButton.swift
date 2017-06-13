//
//  ItemActionButton.swift
//  Basket
//
//  Created by Mario Radonic on 23/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ItemActionButton: UIButton {

    var buttonTitleLabel: UILabel
    var buttonImageView: UIImageView

    var callback: ((MGSwipeTableCell) -> Bool)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        buttonTitleLabel = UILabel()
        buttonImageView = UIImageView()

        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        buttonTitleLabel = UILabel()
        buttonImageView = UIImageView()
        super.init(coder: aDecoder)
    }

    init(itemAction: BasketItemAction) {
        let frame = CGRect(x: 0, y: 0, width: 72, height: 65)
        buttonTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 15))
        buttonImageView = UIImageView(image: UIImage(named: itemAction.iconName))

        super.init(frame: frame)

        buttonTitleLabel.font = UIFont.bsktSmallBoldFont()
        buttonTitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        buttonTitleLabel.text = itemAction.title
        buttonTitleLabel.highlightedTextColor = UIColor.white.withAlphaComponent(0.5)
        addSubview(buttonTitleLabel)

        buttonImageView.contentMode = UIViewContentMode.scaleAspectFill
        buttonImageView.image = UIImage(named: itemAction.iconName)
        buttonImageView.highlightedImage = UIImage(named: itemAction.iconName)?.imageWithAlpha(0.5)
        addSubview(buttonImageView)

        buttonImageView.autoPinEdge(.top, to: .top, of: self, withOffset: 14)
        buttonImageView.autoAlignAxis(.vertical, toSameAxisOf: self)
        buttonTitleLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
        buttonTitleLabel.autoPinEdge(.top, to: .bottom, of: buttonImageView, withOffset: 8)

        setBackgroundImage(UIImage.imageWithColor(itemAction.backgroundColor, andSize: frame.size), for: UIControlState())
    }

    override var isHighlighted: Bool {
        didSet {
            buttonImageView.isHighlighted = isHighlighted
            buttonTitleLabel.isHighlighted = isHighlighted
        }
    }

    func callMGSwipeConvenienceCallback(_ sender: MGSwipeTableCell) -> Bool {
        if let callback = callback {
            return callback(sender)
        }
        return false
    }
}
