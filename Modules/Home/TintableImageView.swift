//
//  TintableImageView.swift
//  Basket
//
//  Created by Mario Radonic on 09/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import PureLayout

class TintableImageView: UIImageView {

    var circleLayer: CALayer?
    var sameImage: UIImageView!
    var isTinted = false
    var handleHeight: CGFloat = 44

    let tintScaleAnimationKey = "tintScale"
    let minScale:CGFloat = 0.001

    let tintOnDuration:TimeInterval = 0.35
    let tintOffDuration:TimeInterval = 0.15

    override func awakeFromNib() {
        super.awakeFromNib()

        sameImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        sameImage.image = self.image
        sameImage.contentMode = self.contentMode
        self.addSubview(sameImage)

        sameImage.autoPinEdgesToSuperviewEdges()

        let tintLayer = CALayer()
        tintLayer.bounds = self.bounds
        tintLayer.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        tintLayer.backgroundColor = UIColor.bsktWindowsBlueColor().cgColor
        tintLayer.opacity = 0.5

        let tintMask = CALayer()
        tintMask.bounds = self.bounds
        tintMask.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        tintMask.contents = self.image?.cgImage

        tintLayer.mask = tintMask

        sameImage.layer.addSublayer(tintLayer)
        sameImage.isHidden = true

        circleLayer = CALayer()
        var maxSide = max(self.bounds.height, self.bounds.width)
        maxSide = maxSide * 2
        circleLayer!.frame = CGRect(x: (self.bounds.size.width - maxSide)/2, y: handleHeight - maxSide/2, width: maxSide, height: maxSide)
        circleLayer!.backgroundColor = UIColor.bsktWindowsBlueColor().cgColor
        circleLayer!.cornerRadius = maxSide / 2

        addScale(minScale, withDuration: 0.01, toLayer: circleLayer!)
        self.sameImage.layer.mask = circleLayer
    }

    func tintImage() {
        sameImage.isHidden = false

        if !isTinted {
            isTinted = true
            addScale(1, withDuration: tintOnDuration, toLayer: circleLayer!)
        }
    }

    func removeTint() {
        if isTinted {
            isTinted = false
            addScale(minScale, withDuration: tintOffDuration, toLayer: circleLayer!)
        }
    }

    func addScale(_ scale: CGFloat, withDuration duration: TimeInterval, toLayer layer:CALayer) -> Void {
        UIView.animate(withDuration: duration) {
            self.circleLayer!.transform = CATransform3DMakeScale(scale, scale, 1)
        }
    }
}
