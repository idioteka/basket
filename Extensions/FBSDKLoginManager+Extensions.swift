//
//  FBSDKLoginManager+Extensions.swift
//  Basket
//
//  Created by Josip Maric on 20/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import RxSwift
import RxCocoa

extension FBSDKLoginManager {
    class func rx_login(_ vc: UIViewController) -> Observable<FBSDKLoginManagerLoginResult> {
        return Observable.create({ [weak vc] observer -> Disposable in
            let permissions = ["public_profile", "email", "user_friends"]
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withReadPermissions: permissions, from: vc, handler: {
                result, error in
                if let error = error {
                    observer.onError(error)
                } else if (result?.isCancelled)! {
                    observer.onError(
                        NSError(domain: "Facebook", code: 69, userInfo: [NSLocalizedDescriptionKey: "Facebook login canceled"]))
                } else {
                    observer.onNext(result!)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
}
