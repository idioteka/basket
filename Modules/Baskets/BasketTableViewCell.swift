//
//  BasketTableViewCell.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import SwiftDate
import RxSwift
import RxCocoa

class BasketTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var yoursLabel: UILabel!
    @IBOutlet weak var countHolderView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var yoursLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var emojiLabel: UILabel!

    let viewModelSubject = ReplaySubject<BasketViewModel>.create(bufferSize: 1)
    let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        setupAppearance()
        bindViewModel()
    }

    fileprivate func setupAppearance() {
        titleLabel.textColor = UIColor.bsktGreyishBrownColor()
        subtitleLabel.textColor = UIColor.bsktWarmGreyColor()
        yoursLabel.backgroundColor = UIColor.bsktWindowsBlueColor()
        yoursLabel.textColor = UIColor.white

        yoursLabel.layer.cornerRadius = 2
        yoursLabel.layer.masksToBounds = true

        countLabel.layer.shouldRasterize = true

        yoursLabel.font = UIFont.bsktSmallBoldFont()

        countLabel.textColor = UIColor.white
        countHolderView.backgroundColor = UIColor.bsktSalmonColor()

        selectionStyle = .none
    }

    fileprivate func bindViewModel() {
        let description = viewModelSubject.flatMap { $0.descriptionString }
        description.bindTo(subtitleLabel.rx.text).addDisposableTo(disposeBag)
        description.map { $0.isEmpty ? 0 : 6 }.bindTo(yoursLabelLeadingConstraint.rx.constant).addDisposableTo(disposeBag)

        viewModelSubject.flatMap { $0.title }.bindTo(titleLabel.rx.text).addDisposableTo(disposeBag)
        viewModelSubject.flatMap { $0.itemCount }.map { String($0) }.bindTo(countLabel.rx.text).addDisposableTo(disposeBag)
        viewModelSubject.flatMap { $0.yours }.map { !$0 }.bindTo(yoursLabel.rx.isHidden).addDisposableTo(disposeBag)
        viewModelSubject.flatMap { $0.icon }.bindTo(emojiLabel.rx.text).addDisposableTo(disposeBag)
    }

    override func layoutSubviews() {
        countHolderView.layer.cornerRadius = countHolderView.frame.width/2
        super.layoutSubviews()
    }
}
