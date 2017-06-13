//
//  SettingsTableViewCell.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var cheveronImage: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        titleLabel.font = UIFont.bsktBiggerMediumFont()
        titleLabel.textColor = UIColor.bsktGreyishBrownColor()
    }
    
    func populate(_ item: SettingsItem) {
        titleLabel.text = item.title
        cheveronImage.isHidden = item.type.isCheveronHidden
        notificationSwitch.isHidden = item.type.isSwitchHidden
    }
    

   
}
