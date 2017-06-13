//
//  UIImage+Extensions.swift
//  Basket
//
//  Created by Mario Radonic on 09/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

extension UIImage {

    class func imageWithColor(_ color: UIColor, andSize size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func imageWithAlpha(_ value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        
        ctx?.scaleBy(x: 1, y: -1);
        ctx?.translateBy(x: 0, y: -area.size.height);
        ctx?.setBlendMode(.multiply);
        ctx?.setAlpha(value);
        ctx?.draw(self.cgImage!, in: area);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    func toBase64String() -> String? {
        let compression: CGFloat = 1.0
        let imageData = UIImageJPEGRepresentation(self, compression)
        
        let base64Image = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
        
        return base64Image
    }
}
