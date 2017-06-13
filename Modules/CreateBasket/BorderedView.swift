//
//  BorderedView.swift
//  Basket
//
//  Created by Mario Radonic on 5/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

class BorderedView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.bsktWhiteTwoColor() {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var hasTopBorder: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var hasBottomBorder: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        if hasTopBorder {
            let topBorder = rect.topBorderLine
            borderColor.setStroke()
            topBorder.stroke()
        }
        if hasBottomBorder {
            borderColor.setStroke()
            rect.bottomBorderLine.stroke()
        }
    }
}

extension CGRect {
    var topLeftPoint: CGPoint {
        return CGPoint(x: minX, y: minY)
    }
    var topRightPoint: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    var bottomRightPoint: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
    var bottomLeftPoint: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }
}

extension CGPoint {
    func lineTo(_ otherPoint: CGPoint) -> UIBezierPath {
        return UIBezierPath.lineFrom(self, toPoint: otherPoint)
    }
}

extension UIBezierPath {
    static func lineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        return path
    }
}

extension CGRect {
    var topBorderLine: UIBezierPath {
        return topLeftPoint.lineTo(topRightPoint)
    }

    var bottomBorderLine: UIBezierPath {
        return bottomLeftPoint.lineTo(bottomRightPoint)
    }

    func bottomBorderLineWith(offset: CGFloat) -> UIBezierPath {
        var bottomLeftPoint = self.bottomLeftPoint
        bottomLeftPoint.x += offset
        return bottomLeftPoint.lineTo(bottomRightPoint)
    }
}
