//
//  PendingBasketTableViewCell.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift

class PendingBasketTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!

    let disposeBag = DisposeBag()
    var reuseDisposeBag = DisposeBag()

    let viewModelSubject = ReplaySubject<BasketViewModel>.create(bufferSize: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        setupAppeareance()
        bindViewModel()
    }

    fileprivate func setupAppeareance() {
        titleLabel.textColor = UIColor.bsktDarkColor()
        subtitleLabel.textColor = UIColor.bsktGreyishColor()
        selectionStyle = .none
        styleButton(acceptButton)
        styleButton(declineButton)
        acceptButton.backgroundColor = UIColor.bsktAlgaeGreenColor()
        declineButton.backgroundColor = UIColor.bsktPaleRedColor()

        titleLabel.font = UIFont.bsktBigBoldFont()
        subtitleLabel.font = UIFont.bsktMediumMediumFont()
    }

    fileprivate func bindViewModel() {
        viewModelSubject.flatMap { $0.icon }.bindTo(iconLabel.rx.text).addDisposableTo(disposeBag)
        viewModelSubject.flatMap { $0.title }.bindTo(titleLabel.rx.text).addDisposableTo(disposeBag)
        viewModelSubject.flatMap { $0.descriptionString }.bindTo(subtitleLabel.rx.text).addDisposableTo(disposeBag)
    }

    func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 3
        button.titleLabel?.font = UIFont.bsktMediumBoldFont()
    }
}
