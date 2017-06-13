//
//  TOCropViewController+Extensions.swift
//  Basket
//
//  Created by Josip Maric on 21/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import TOCropViewController

extension TOCropViewController {
    
    public var rx_delegate: DelegateProxy {
        return TOCropViewControllerDelegateProxy.proxyForObject(self)
    }

    public var rx_didCropToImage: Observable<UIImage> {
        return rx_delegate.sentMessage(#selector(TOCropViewControllerDelegate.cropViewController(_:didCropToImage:rect:angle:)))
            .map { params in
                return params[1] as! UIImage
        }
    }
}
