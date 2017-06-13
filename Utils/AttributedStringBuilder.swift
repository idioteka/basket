//
//  AttributedStringBuilder.swift
//  Farmigo
//
//  Created by Mario Radonic on 7/14/15.
//  Copyright (c) 2015 Five Minutes Ltd. All rights reserved.
//

import UIKit
import Foundation

class AttributedStringBuilder {
    
    var globalColor: UIColor?
    
    var globalFont: UIFont?
    
    fileprivate var buildedString: NSMutableAttributedString
    
    init(globalColor: UIColor?, globalFont: UIFont?) {
        self.globalColor = globalColor
        self.globalFont = globalFont
        
        buildedString = NSMutableAttributedString()
    }
    
    func appendString(_ aString: String, withFont: UIFont? = nil, andColor: UIColor? = nil, letterSpacing: CGFloat = 0.0) {
        if let aFont = withFont ?? globalFont {
            if let aColor = andColor ?? globalColor {
                _appendString(aString, withFont: aFont, color: aColor, letterSpacing: letterSpacing)
            } else {
                fatalError("Can not append string because color is not specified and there is no global color!")
            }
        } else {
            fatalError("Can not append string because font is not specified and there is no global font!")
        }
    }
    
    fileprivate func _appendString(_ aString: String, withFont: UIFont, color: UIColor, letterSpacing: CGFloat = 0.0) {
        let attributedString = NSAttributedString(string: aString, attributes: [
            NSFontAttributeName: withFont,
            NSForegroundColorAttributeName: color,
            NSKernAttributeName: letterSpacing
            ])
        buildedString.append(attributedString)
    }
    
    func buildString() -> NSAttributedString {
        return buildedString
    }
}
