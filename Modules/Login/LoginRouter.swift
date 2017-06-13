//
//  LoginRouter.swift
//  Basket
//
//  Created by Mario Radonic on 2/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginRouter: BaseRouter {

    fileprivate let disposeBag = DisposeBag()
    fileprivate let authService: AuthenticationService

    init(authService: AuthenticationService) {
        self.authService = authService
    }

    func showIn(_ window: UIWindow) {
        let landingVc = LandingViewController.initFromSameNamedNib()

        addViewController(landingVc)

        let nvc = UINavigationController(rootViewController: landingVc)
        window.rootViewController = nvc

        landingVc.loginButtonTapped.drive(onNext: { [weak self] in
            self?.showLoginScreenIn(nvc)
        }).addDisposableTo(disposeBag)

        landingVc.signupButtonTapped.drive(onNext: {
            let signupRouter = SignupRouter()
            signupRouter.showIn(nvc)
        }).addDisposableTo(disposeBag)

        landingVc.rxViewDidLoad.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }

            let viewModel = LandingViewModel(
                facebookLoginResult: landingVc.facebookLoginResult,
                authenticationService: self.authService
            )

            landingVc.viewModel = viewModel
        }).addDisposableTo(disposeBag)
    }

    func showLoginScreenIn(_ navigationController: UINavigationController) {
        let loginViewController = LoginViewController.initFromSameNamedNib()

        addViewController(loginViewController)

        loginViewController.rxViewDidLoad.subscribe(onNext: {
            let viewModel = LoginViewModel(inputs: loginViewController.outputs, authenticationService: AppDependencies.shared.authenticationService)
            loginViewController.viewModel = viewModel
        }).addDisposableTo(disposeBag)

        navigationController.pushViewController(loginViewController, animated: true)
    }

}
