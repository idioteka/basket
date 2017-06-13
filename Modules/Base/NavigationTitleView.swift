//
//  NavigationTitleView.swift
//  Basket
//
//  Created by Mario Radonic on 23/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import PureLayout

class NavigationTitleContent: Equatable {
    let title: String
    let subtitle: String?
    let imageName: String?

    init(title: String, subtitle: String?, imageName: String?) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
}

func ==(lhs: NavigationTitleContent, rhs: NavigationTitleContent) -> Bool {
    return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.imageName == rhs.imageName
}

class NavigationTitleView: UIView {

    var titleLabel: UILabel
    var subtitleLabel: UILabel
    var imageView: UIImageView

    override init(frame: CGRect) {
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        imageView = UIImageView()
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        imageView = UIImageView()
        super.init(coder: aDecoder)
    }

    init(title: String, subtitle: String?, imageName: String?) {
        let frame = CGRect(x: 0, y: 0, width: 80, height: 44)

        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        subtitleLabel = UILabel(frame: CGRect(x: 0, y: 22, width: 0, height: 0))
        imageView = UIImageView(image: UIImage(named: imageName ?? ""))

        super.init(frame: frame)

        let color = UIColor.white
        let titleFont = UIFont.bsktMediumBoldFont()
        let subtitleFont = UIFont.bsktSmallMediumFont()

        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let builder = AttributedStringBuilder(globalColor: color, globalFont: titleFont)
        builder.appendString(title.uppercased(), letterSpacing: 2.0)
        titleLabel.attributedText = builder.buildString()

        titleLabel.sizeToFit()
        subtitleLabel = UILabel(frame: CGRect(x: 0, y: 22, width: 0, height: 0))

        addSubview(titleLabel)

        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.font = subtitleFont
            subtitleLabel.textColor = color.withAlphaComponent(0.75)
            subtitleLabel.sizeToFit()
            addSubview(subtitleLabel)
            subtitleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 4)
            titleLabel.autoPinEdge(.bottom, to: .top, of: subtitleLabel)
        } else {
            titleLabel.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -11)
        }

        if let _ = imageName {
            imageView.contentMode = .scaleAspectFill
            addSubview(imageView)
            imageView.autoAlignAxis(.horizontal, toSameAxisOf: titleLabel, withOffset: -1)
            imageView.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 6)
            titleLabel.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -4)
        } else {
            titleLabel.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 0)
        }
    }
}
