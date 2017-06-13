//
//  SignupViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 2/13/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum SignupError {
    case fieldsError
    case emailExists
    case serverError
}

enum SignupResult {
    case notSignedUp
    case userSignedUp(tokens: APITokens)
    case errored(error: SignupError)
}

struct SignupViewModelInputs {
    let signupDetailsChanged: Driver<(SignupInputField, String)>
    let signupTapped: Driver<Void>
}

class SignupViewModel {

    let signupEnabled: Driver<Bool>
    let signupResult: Driver<SignupResult>

    let errorMessage: Driver<String>
    let disposeBag = DisposeBag()

    init(inputs: SignupViewModelInputs, authenticationService: AuthenticationService) {
        let signupDetails = inputs.signupDetailsChanged.scan(UserSignupDetails.empty) { (a, x) in
            var updatedInput = a
            switch x.0 {
            case .firstName:
                updatedInput.firstName = x.1
            case .lastName:
                updatedInput.lastName = x.1
            case .email:
                updatedInput.email = x.1
            case .password:
                updatedInput.password = x.1
            }
            return updatedInput
        }

        self.signupEnabled = signupDetails.map { $0.valid }.distinctUntilChanged()

        let signupResult = inputs.signupTapped
            .withLatestFrom(signupDetails)
            .asObservable()
            .flatMap { authenticationService.signupWith($0) }
            .startWith(SignupResult.notSignedUp)
            .asDriver(onErrorJustReturn: SignupResult.errored(error: SignupError.serverError))

        self.signupResult = signupResult
        self.errorMessage = signupResult.mapAndFilterNil { (result) -> (SignupError?) in
            switch result {
            case .errored(error: let error): return error
            default: return nil
            }
        }.map { (error) -> (String) in
            switch error {
            case .emailExists:
                return "Email already exists"
            case .fieldsError:
                return "Make sure that all fields are properly entered."
            case .serverError:
                return "There was an error, please try again"
            }
        }
    }
}
