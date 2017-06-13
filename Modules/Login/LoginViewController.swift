//
//  LoginViewController.swift
//  Basket
//
//  Created by Mario Radonic on 2/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FBSDKLoginKit

class LoginViewController: BaseViewController, FacebookLoginViewController {
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!

    @IBOutlet weak var loginFacebookButton: RoundedButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var textfieldsContainer: UIView!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    var facebookLoginButtonTapped: Driver<Void> {
        return safeButtonTap { [weak self] in self?.loginFacebookButton }
    }

    var forgotPasswordEmail: Driver<String> {
        return forgotPasswordButton.rx.tap.flatMap { [weak self] _ -> Observable<String> in
            guard let view = self else {
                return Observable.empty()
            }
            return view.showforgotPasswordAlert()
        }.asDriver(onErrorJustReturn: "")
    }

    var viewControllerForFacebookLogin: UIViewController {
        return self
    }

    var viewModel: LoginViewModel!

    let disposeBag = DisposeBag()

    var outputs: LoginViewOutputs {
        return LoginViewOutputs(
            email: emailTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            loginTapped: loginButton.rx.tap.asDriver(),
            facebookLoginResult: facebookLoginResult,
            forgotPasswordEmail: forgotPasswordEmail
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)

        applyDesign()

        viewModel.loginEnabled
            .drive(loginButton.rx.isEnabled)
            .addDisposableTo(disposeBag)

        viewModel.errorMessage
            .drive(simpleAlertWithTitle("Error"))
            .addDisposableTo(disposeBag)

        viewModel.forgotPasswordSent.drive().addDisposableTo(disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false

        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.isTranslucent = true
    }

    func applyDesign() {
        textfieldsContainer.layer.cornerRadius = 4

        emailTextField.setCustomPlaceholder("Email address")
        passwordTextField.setCustomPlaceholder("Password")

        [loginFacebookButton, loginButton].forEach { $0.titleLabel?.font = UIFont.bsktBigBoldFont() }

        forgotPasswordButton.titleLabel?.font = UIFont.bsktMediumMediumFont()
        forgotPasswordButton.setTitleColor(UIColor.bsktSalmonColor(), for: UIControlState())

        let disabledImage = UIImage.imageWithColor(UIColor.bsktWarmGreyColor(), andSize: CGSize(width: 10, height: 10))
        loginButton.setImage(disabledImage, for: .disabled)
    }

    override func preferrsNavigationBarTransparent() -> Bool {
        return true
    }

    func showforgotPasswordAlert() -> Observable<String> {

        return Observable.create { observer -> Disposable in
            let alert = UIAlertController(title: "Forgot Password", message: "Enter your account e-mail and we will send you instructions on how to reset your password.", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                observer.onCompleted()
            })
            alert.addAction(cancelAction)

            alert.addTextField { textField in
                textField.placeholder = "Email"
            }

            let sendAction = UIAlertAction(title: "Send", style: .default, handler: { _ in
                let textField = alert.textFields![0] as UITextField
                observer.onNext(textField.text ?? "")
                observer.onCompleted()
            })
            alert.addAction(sendAction)

            self.present(alert, animated: true, completion: nil)

            return Disposables.create()
        }
    }

}
