//
//  SplitBillHeaderView.swift
//  Basket
//
//  Created by Mario Radonic on 30/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class SplitBillHeaderView: UIView {

    @IBOutlet weak var splitBillTotalLabel: UILabel!
    @IBOutlet weak var spentSoFarLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        splitBillTotalLabel.font = UIFont.bsktBiggestBoldFont()
        splitBillTotalLabel.textColor = UIColor.black.withAlphaComponent(0.75)
        spentSoFarLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        spentSoFarLabel.font = UIFont.bsktMediumBoldFont()
    }
    
    func populate(_ amount: Double?) {
        let total = amount ?? 0
        splitBillTotalLabel.text = "\(total)"
    }
}
