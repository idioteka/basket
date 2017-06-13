//
//  AddFriendResultCell.swift
//  Basket
//
//  Created by Mario Radonic on 4/24/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class AddFriendResultCell: UITableViewCell {

    fileprivate let permanentDisposeBag = DisposeBag()

    var disposeBag = DisposeBag()
    let user = PublishSubject<User>()
    let isFirst = Variable<Bool>(false)
    let isLast = Variable<Bool>(false)

    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var emailLabel: UILabel!
    @IBOutlet fileprivate weak var isAddedImageView: UIImageView!

    var isAdded: Bool = true {
        didSet {
            isAddedImageView.image = isAdded ? UIImage(named: "removePerson") : UIImage(named: "addPerson")
            emailLabel.isHidden = isAdded
        }
    }

    let borderColor = UIColor.bsktWhiteTwoColor()

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.clipsToBounds = true

        user.asObservable().subscribe(onNext: { [weak self] user in
            self?.nameLabel.text = user.name
            self?.emailLabel.text = user.email

            if let avatar = user.avatar, let avatarUrl = URL(string: avatar) {
                self?.avatarImageView.kf.setImage(with: avatarUrl)
                // TODO: handle reuse and placeholder
            }
        }).addDisposableTo(permanentDisposeBag)

        Driver.combineLatest(isFirst.asDriver().distinctUntilChanged(), isLast.asDriver().distinctUntilChanged()) { (first, last) -> Void in
        }.drive(onNext: { [weak self] in
            self?.setNeedsDisplay()
        }).addDisposableTo(permanentDisposeBag)
        nameLabel.font = UIFont.bsktBigBoldFont()
        nameLabel.textColor = UIColor.bsktGreyishBrownColor()
        emailLabel.font = UIFont.bsktSmallMediumFont()
        emailLabel.textColor = UIColor.bsktWarmGreyTwoColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width/2
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if isFirst.value {
            let topBorder = rect.topBorderLine
            borderColor.setStroke()
            topBorder.stroke()
        }

        if isLast.value {
            borderColor.setStroke()
            rect.bottomBorderLine.stroke()
        } else {
            borderColor.setStroke()
            rect.bottomBorderLineWith(offset: 15).stroke()
        }
    }
}
