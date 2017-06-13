//
//  LoginViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 2/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import FBSDKLoginKit

enum LoginError {
    case passwordIncorrect
    case emailNotFound
    case other
}

enum LoginResult {
    case success(tokens: APITokens)
    case error(error: LoginError)
}

typealias LoginViewOutputs = LoginViewModelInputs

struct LoginViewModelInputs {
    let email: Driver<String>
    let password: Driver<String>
    let loginTapped: Driver<Void>
    let facebookLoginResult: Driver<FBSDKLoginManagerLoginResult?>
    let forgotPasswordEmail: Driver<String>
}

class LoginViewModel: FacebookLoginViewModel {
    // Outputs
    let loginEnabled: Driver<Bool>
    let loginResult: Driver<LoginResult>
    let forgotPasswordSent: Driver<Bool>
    var errorMessage: Driver<String> {
        let mailLoginError = loginResult
            .mapAndFilterNil { (result) -> LoginError? in
                switch result {
                case .error(let error): return error
                default: return nil
                }
            }
        return Driver.of(mailLoginError, facebookError).merge()
            .map { (error) -> String in
                switch error {
                case .emailNotFound:
                    return "Email not found"
                case .passwordIncorrect:
                    return "Password is not correct"
                case .other:
                    return "There was an error, please try again"
                }
            }
    }

    let disposeBag = DisposeBag()

    let facebookLoginResult: Driver<FBSDKLoginManagerLoginResult?>
    let authenticationService: AuthenticationService

    init(inputs: LoginViewModelInputs, authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
        self.facebookLoginResult = inputs.facebookLoginResult

        self.forgotPasswordSent = inputs.forgotPasswordEmail.asObservable().flatMapLatest {
            authenticationService.sendForgotPassword($0)
        }.asDriver(onErrorJustReturn: false)

        let userCredentials = Observable.combineLatest(inputs.email.asObservable(), inputs.password.asObservable()) { email, password in
                return LoginDetails(email: email, password: password)
            }
            .startWith(LoginDetails.empty)
            .asDriver(onErrorJustReturn: LoginDetails.empty)

        loginEnabled = userCredentials.map {
            // TODO: Validate email here and password length maybe
            return $0.email.characters.count > 3 && $0.password.characters.count > 5
        }

        self.loginResult = inputs.loginTapped.withLatestFrom(userCredentials).asObservable()
            .flatMapLatest { authenticationService.loginWith($0) }
            .asDriver(onErrorJustReturn: .error(error: LoginError.other))


    }

}
