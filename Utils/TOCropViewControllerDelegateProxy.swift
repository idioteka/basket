//
//  TOCropViewControllerDelegateProxy.swift
//  Basket
//
//  Created by Josip Maric on 21/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import TOCropViewController

class TOCropViewControllerDelegateProxy: DelegateProxy, TOCropViewControllerDelegate, DelegateProxyType {

    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let vc: TOCropViewController = object as! TOCropViewController
        return vc.delegate
    }

    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let vc: TOCropViewController = object as! TOCropViewController
        vc.delegate = delegate as? TOCropViewControllerDelegate
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(TOCropViewControllerDelegate.cropViewController(_:didCropToImage:rect:angle:)) {
            return false
        }
        return super.responds(to: aSelector)
    }
}
