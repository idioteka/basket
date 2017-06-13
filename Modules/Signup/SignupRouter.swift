//
//  SignupRouter.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift

class SignupRouter: BaseRouter {
    let disposeBag = DisposeBag()

    func showIn(_ navigationController: UINavigationController) {
        let signupViewController = SignupViewController.initFromSameNamedNib()

        addViewController(signupViewController)
        signupViewController.rxViewDidLoad.subscribe(onNext: {
            let vm = SignupViewModel(inputs: signupViewController.outputs, authenticationService: AppDependencies.shared.authenticationService) // TODO: Add to dependencies
            signupViewController.viewModel = vm
        }).addDisposableTo(disposeBag)

        navigationController.pushViewController(signupViewController, animated: true)
    }
}
