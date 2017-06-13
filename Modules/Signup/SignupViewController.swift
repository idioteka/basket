//
//  SignupViewController.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignupViewController: BaseViewController {

    @IBOutlet var borderViews: [UIView]!
    var viewModel: SignupViewModel!

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var firstNameTextField: LoginTextField!
    @IBOutlet weak var lastNameTextField: LoginTextField!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var textFieldsContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    let disposeBag = DisposeBag()

    var outputs: SignupViewModelInputs!

    var firstNameChanged: Driver<String> {
        return safeRxText { [weak self] in self?.firstNameTextField }
    }

    var lastNameChanged: Driver<String> {
        return safeRxText { [weak self] in self?.lastNameTextField }
    }

    var emailChanged: Driver<String> {
        return safeRxText { [weak self] in self?.emailTextField }
    }

    var passwordChanged: Driver<String> {
        return safeRxText { [weak self] in self?.passwordTextField }
    }

    override func viewDidLoad() {
        let inputChanged = Driver.of(
            firstNameChanged.map { (SignupInputField.firstName, $0) },
            lastNameChanged.map { (SignupInputField.lastName, $0) },
            emailChanged.map { (SignupInputField.email, $0) },
            passwordChanged.map { (SignupInputField.password, $0) }
        ).merge()
        let signupTapped = signupButton.rx.tap.asDriver(onErrorJustReturn: ())

        self.outputs = SignupViewModelInputs(signupDetailsChanged: inputChanged, signupTapped: signupTapped)

        super.viewDidLoad()
        assert(viewModel != nil)

        viewModel.signupResult.drive(onNext: { result in
            switch result {
            case .errored(let error):
                print(error)
            case .notSignedUp:
                break
            case .userSignedUp(_):
                break
            }
        }).addDisposableTo(disposeBag)

        borderViews.forEach {
            $0.backgroundColor = UIColor.bsktWhite2Color()
        }

        firstNameTextField.setCustomPlaceholder("First name")
        lastNameTextField.setCustomPlaceholder("Last name")
        emailTextField.setCustomPlaceholder("Email address")
        passwordTextField.setCustomPlaceholder("Password (at least 8 characters)")

        textFieldsContainer.layer.cornerRadius = 4
        titleLabel.font = UIFont.bsktHugeDemiBoldFont()
        subtitleLabel.font = UIFont.bsktBigMediumFont()
        signupButton.titleLabel?.font = UIFont.bsktBigBoldFont()

        viewModel.errorMessage
            .drive(simpleAlertWithTitle("Error"))
            .addDisposableTo(disposeBag)
    }

    override func preferrsNavigationBarTransparent() -> Bool {
        return true
    }
}
