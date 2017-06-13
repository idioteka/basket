//
//  SettingsSectionFooterView.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class SettingsSectionFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        titleLabel.font = UIFont.bsktSmallishRegularFont()
        titleLabel.textColor = UIColor.bsktWarmGreyColor()
    }
    
    func populate(_ title: String) {
        titleLabel.text = title
    }

}
