//
//  ActivityTableViewCell.swift
//  Basket
//
//  Created by Mario Radonic on 01/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ActivityTableViewCell: UITableViewCell {

    var reuseDisposeBag = DisposeBag()
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
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
        iconLabel.font = UIFont.bsktEmojiMediumFont()
        messageLabel.font = UIFont.bsktMediumBoldFont()
        timeLabel.font = UIFont.bsktSmallishMediumFont()
        timeLabel.textColor = UIColor.bsktWarmGreyColor()
        separatorView.backgroundColor = UIColor.bsktWhite2Color()
    }
    
    func populate(_ activity: BasketActivity) {
        iconLabel.text = activity.icon?.toEmoji()
        
        if let message = activity.message {
            let html = "<span style=\"font-family: 'Avenir Next';\">\(message)</span>"
            if let data = html.data(using: String.Encoding.utf8) {
                let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                // attributedString?.setAttributes([NSFontAttributeName: UIFont.bsktMediumMediumFont()!], range: NSMakeRange(0, attributedString!.length))
                messageLabel.attributedText = attributedString
            }
        }
        
        timeLabel.text = activity.pretyTime
    }
}
