//
//  LandingViewController.swift
//  Basket
//
//  Created by Mario Radonic on 4/30/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FBSDKLoginKit

protocol FacebookLoginViewController: class {
    var facebookLoginButtonTapped: Driver<Void> { get }
    var viewControllerForFacebookLogin: UIViewController { get }
}

extension FacebookLoginViewController {
    var facebookLoginResult: Driver<FBSDKLoginManagerLoginResult?> {
        return facebookLoginButtonTapped.asObservable().flatMap { [weak self] _ -> Observable<FBSDKLoginManagerLoginResult?> in
            guard let view = self else { return Observable.empty() }
            return FBSDKLoginManager.rx_login(view.viewControllerForFacebookLogin)
                .map { $0 as FBSDKLoginManagerLoginResult? }
                .catchErrorJustReturn(nil)
        }.asDriver(onErrorDriveWith: Driver.empty())
    }
}

class LandingViewController: BaseViewController, FacebookLoginViewController {

    @IBOutlet weak fileprivate var shoppingLabel: UILabel!
    @IBOutlet weak fileprivate var signupWithFacebookButton: RoundedButton!
    @IBOutlet weak fileprivate var loginButton: UIButton!
    @IBOutlet weak fileprivate var signupButton: RoundedButton!

    var viewModel: LandingViewModel!

    let disposeBag = DisposeBag()

    var loginButtonTapped: Driver<Void> {
        return safeButtonTap { [weak self] in self?.loginButton }
    }

    var signupButtonTapped: Driver<Void> {
        return safeButtonTap { [weak self] in self?.signupButton }
    }

    var facebookLoginButtonTapped: Driver<Void> {
        return safeButtonTap { [weak self] in self?.signupWithFacebookButton }
    }

    var viewControllerForFacebookLogin: UIViewController {
        return self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [signupButton, signupWithFacebookButton, loginButton].forEach {
            $0.titleLabel?.font = UIFont.bsktBigBoldFont()
        }

        shoppingLabel.font = UIFont.bsktBiggerBoldFont()

        viewModel.facebookError
            .map { _ in "Facebook login error" }
            .drive(simpleAlertWithTitle("Error"))
            .addDisposableTo(disposeBag)
    }

    override func preferrsNavigationBarTransparent() -> Bool {
        return true
    }
}
