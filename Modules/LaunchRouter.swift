//
//  LaunchRouter.swift
//  Basket
//
//  Created by Mario Radonic on 9/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift

class LaunchRouter {
    fileprivate let disposeBag = DisposeBag()
    fileprivate let authService: AuthenticationService
    fileprivate let window: UIWindow

    init(window: UIWindow, authService: AuthenticationService) {
        self.authService = authService
        self.window = window
    }

    func startApplication() {
        authService.loginStatus.distinctUntilChanged { lhs, rhs -> Bool in
            switch (lhs, rhs) {
            case (.loggedIn, .loggedIn): return true
            case (.notLoggedIn, .notLoggedIn): return true
            default: return false
            }
        }.subscribe(onNext: { status in
            switch status {
            case .loggedIn(let tokens):
                self.startHomeScreen(tokens, authService: self.authService)
            case .notLoggedIn:
                self.startLogin()
            }
        }).addDisposableTo(disposeBag)
    }

    func startHomeScreen(_ tokens: APITokens, authService: AuthenticationService) {
        let networking = AuthorizedNetworking(tokens: tokens)
        let basketRouter = BasketsRouter(
            networking: networking,
            userID: tokens.userId,
            authService: authService
        )

        basketRouter.startIn(window)
    }

    func startLogin() {
        let loginRouter = LoginRouter(authService: authService)
        loginRouter.showIn(window)
    }
}
