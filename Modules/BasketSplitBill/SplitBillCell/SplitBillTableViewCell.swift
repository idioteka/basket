//
//  SplitBillTableViewCell.swift
//  Basket
//
//  Created by Mario Radonic on 30/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SplitBillTableViewCell: UITableViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width / 2
        avatarImageView.layer.masksToBounds = true
        nameLabel.font = UIFont.bsktBigBoldFont()
        nameLabel.textColor = UIColor.bsktGreyishBrownColor()
        separatorView.backgroundColor = UIColor.bsktWhite2Color()
        avatarImageView.image = nil
    }
    
    func populate(_ billItem: BillItem) {
        nameLabel.text = billItem.person?.name ?? ""
        let globalColor = UIColor.bsktWarmGreyColor()
        let globalFont = UIFont.bsktMediumBoldFont()
        
        let stringBuilder = AttributedStringBuilder(globalColor: globalColor, globalFont: globalFont)
        let ownesText = billItem.amount > 0 ? "is owed " : "owes "
        stringBuilder.appendString(ownesText)
        let priceColor = billItem.amount > 0 ? UIColor.bsktAlgaeGreenColor() : UIColor.bsktCoralColor()
        stringBuilder.appendString("\(billItem.amount)", andColor: priceColor)
        amountLabel.attributedText = stringBuilder.buildString()
        
        if
            let avatar = billItem.person?.avatar,
            let avatarULR = URL(string: avatar) {
                avatarImageView.kf.setImage(with: avatarULR)
        }
    }
    
}
