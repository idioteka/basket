//
//  ItemTableViewCell.swift
//  Basket
//
//  Created by Mario Radonic on 28/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RxSwift
import RxCocoa
import Kingfisher

class ItemTableViewCell: MGSwipeTableCell {

    var reuseDisposeBag = DisposeBag()

    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var statusIndicatorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var actionedByImageView: UIImageView!
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var recommendationIcon: UIImageView!

    var editbutton: ItemActionButton?
    var deleteButton: ItemActionButton?
    var buyButton: ItemActionButton?
    var reserveButton: ItemActionButton?
    var unreserveButton: ItemActionButton?

    var viewModel: ItemCellViewModel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createButtons()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createButtons()
    }

    func createButtons() {
        editbutton = createSwipeButton(.edit(""))
        deleteButton = createSwipeButton(.delete)
        buyButton = createSwipeButton(.buy(nil))
        reserveButton = createSwipeButton(.reserve)
        unreserveButton = createSwipeButton(.unreserve)
    }

    fileprivate let itemActionSubject = PublishSubject<BasketItemAction>()
    var itemAction: ControlEvent<BasketItemAction> {
        return ControlEvent(events: itemActionSubject)
    }

    fileprivate let reuseSubject = PublishSubject<Void>()
    var rxReused: ControlEvent<Void> {
        return ControlEvent(events: reuseSubject)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
        reuseSubject.onNext()
    }

    func setup() {
        titleLabel.textColor = UIColor.bsktDarkColor()
        priceLabel.textColor = UIColor.bsktAlgaeGreenColor()
        actionedByImageView.layer.cornerRadius = actionedByImageView.frame.size.height / 2.0
        actionedByImageView.layer.masksToBounds = true
        actionedByImageView.backgroundColor = UIColor.white
        separatorView.backgroundColor = UIColor.bsktWhite2Color()
        titleLabel.font = UIFont.bsktBigBoldFont()
        priceLabel.font = UIFont.bsktSmallishBoldFont()
    }

    func populate(_ viewModel: ItemCellViewModel) {
        reuseDisposeBag = DisposeBag()

        viewModel.title.asObservable()
            .bindTo(titleLabel.rx.text)
            .addDisposableTo(reuseDisposeBag)

        viewModel.price.asObservable()
            .bindTo(priceLabel.rx.text)
            .addDisposableTo(reuseDisposeBag)

        viewModel.statusImage.asObservable()
            .bindTo(statusIndicatorImageView.rx.image)
            .addDisposableTo(reuseDisposeBag)

        viewModel.actionedByAvatar.drive(onNext: { [weak self] (imageURL) in
            if let imageURL = imageURL {
                self?.actionedByImageView.kf.setImage(with: imageURL)
            }
        }).addDisposableTo(reuseDisposeBag)

        viewModel.recommendationText.asObservable().map { (recommendation) -> NSAttributedString? in
            guard let recommendation = recommendation else {
                return nil
            }
            let color = UIColor.bsktWarmGreyColor()
            let font = UIFont.bsktSmallishMediumFont()
            let builder = AttributedStringBuilder(globalColor: color, globalFont: font)
            builder.appendString("We recommend ")
            let recommendationColor = UIColor.bsktSalmonColor()
            builder.appendString(recommendation, withFont: font, andColor: recommendationColor)
            return builder.buildString()
        }.bindTo(recommendationLabel.rx.attributedText).addDisposableTo(reuseDisposeBag)

        viewModel.recommendationText.asObservable().map { (recommendation) -> UIImage? in
            guard let _ = recommendation else {
                return nil
            }
            return UIImage(named: "itemRecommendationIcon")
        }.bindTo(recommendationIcon.rx.image).addDisposableTo(reuseDisposeBag)

        viewModel.rightButtons.map { result -> [UIView] in
            return result.map { self.basketActionButtonForAction($0) }
        }.drive(onNext: { [weak self] in
            self?.rightButtons = $0
            self?.refreshButtons(false)
        }).addDisposableTo(reuseDisposeBag)
    }

    fileprivate func basketActionButtonForAction(_ action: BasketItemAction) -> ItemActionButton {
        switch action {
        case .buy(_):
            return buyButton!
        case .delete:
            return deleteButton!
        case .edit(_):
            return editbutton!
        case .reserve:
            return reserveButton!
        case .unreserve:
            return unreserveButton!
        }
    }

    fileprivate func createSwipeButton(_ itemAction: BasketItemAction) -> ItemActionButton {
        let button = ItemActionButton(itemAction: itemAction)
        button.callback = { [weak self] _ in
            guard let cell = self else { return false }
            cell.hideSwipe(animated: true)
            cell.itemActionSubject.onNext(itemAction)
            return true
        }

        return button
    }
}
