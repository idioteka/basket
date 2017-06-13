//
//  AuthenticationService.swift
//  Basket
//
//  Created by Mario Radonic on 4/2/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import RxSwift
import Moya
import AERecord
import FBSDKLoginKit

enum LoginStatus {
    case loggedIn(tokens: APITokens)
    case notLoggedIn
}

class AuthenticationService {

    let networking: Networking

    let loginStatus = ReplaySubject<LoginStatus>.create(bufferSize: 1)

    init(networking: Networking) {
        self.networking = networking

        if let tokens = fetchTokensFromDatabase() {
            loginStatus.onNext(LoginStatus.loggedIn(tokens: tokens))
        } else {
            loginStatus.onNext(LoginStatus.notLoggedIn)
        }
    }

    func fetchTokensFromDatabase() -> APITokens? {
        return try? APITokens.retreiveFromKeychain()
    }

    func signupWith(_ signupDetails: UserSignupDetails) -> Observable<SignupResult> {
        let token = BasketAPI.signup(userSignupDetails: signupDetails)
        let provider = networking.provider

        return provider.request(token)
            .filterSuccessfulStatusAndRedirectCodes()
            .map { response -> SignupResult in
                let tokens = try self.apiTokensFromSignupOrLoginResponse(response)
                self.loginStatus.onNext(LoginStatus.loggedIn(tokens: tokens))
                return SignupResult.userSignedUp(tokens: tokens)
            }.catchError { (error) -> Observable<SignupResult> in
                return Observable.just(AuthenticationService.mapSignupErrorToSignupResult(error: error))
            }
    }

    func loginWith(_ loginDetails: LoginDetails) -> Observable<LoginResult> {
        let token = BasketAPI.login(loginDetails: loginDetails)
        let provider = networking.provider

        return provider.request(token)
            .filterSuccessfulStatusAndRedirectCodes()
            .map { [weak self] response -> LoginResult in
                guard let service = self else { return LoginResult.error(error: LoginError.other) }
                let tokens = try service.apiTokensFromSignupOrLoginResponse(response)
                service.loginStatus.onNext(LoginStatus.loggedIn(tokens: tokens))

                return LoginResult.success(tokens: tokens)
            }.catchError { error -> Observable<LoginResult> in
                return Observable.just(AuthenticationService.mapLoginErrorToLoginResult(error: error))
            }
    }

    func loginWithFacebookResult(_ result: FBSDKLoginManagerLoginResult) -> Observable<LoginResult> {
        guard let accessToken = result.token.tokenString else {
            return Observable.empty()
        }

        let token = BasketAPI.facebookLogin(accessToken: accessToken)
        let provider = networking.provider
        return provider.request(token).filterSuccessfulStatusAndRedirectCodes()
            .map { [weak self] response -> LoginResult in
                guard let service = self else { return LoginResult.error(error: LoginError.other) }

                let tokens = try service.apiTokensFromSignupOrLoginResponse(response)
                service.loginStatus.onNext(LoginStatus.loggedIn(tokens: tokens))
                return LoginResult.success(tokens: tokens)
            }.catchError { error -> Observable<LoginResult> in
                if let error = error as? Moya.Error {
                    return Observable.just(AuthenticationService.mapLoginErrorToLoginResult(error: error))
                }
                return Observable.just(LoginResult.error(error: LoginError.other))
            }
    }

    func logout() {
        APITokens.deleteFromKeychain()
        AERecord.truncateAllData()
        AERecord.save()
        loginStatus.onNext(LoginStatus.notLoggedIn)
    }

    func sendForgotPassword(_ email: String) -> Observable<Bool> {
        let token = BasketAPI.forgotPassword(email: email)
        return networking.provider.request(token).map { _ in return true }
    }

    /**
     Signup and login both have same response - they contain user details and access and refresh token.

     This method tries to parse that response and get this information. It also saves tokens to keychain,
     as it is assumed that when signup or login responses are received signup/login process is in progress.

     - parameter response: Moya Response received from server

     - returns: APITokens contained in response
     */
    fileprivate func apiTokensFromSignupOrLoginResponse(_ response: Response) throws -> APITokens {
        let json = try response.mapJSONDictionry()
        let user = try User.createWith(jsonDictionary: json)
        let tokens = try APITokens(json: json, userId: Int(user.id))

        do {
            try tokens.saveToKeychain() // TODO: Map function should not have side effects, and saving tokens to keychain is one
        } catch let error {
            print(error)
            throw error
        }

        AERecord.saveAndWait()

        return tokens
    }

    private static func mapSignupErrorToSignupResult(error: Swift.Error) -> SignupResult {
        if let error = error as? Moya.Error {
            switch error {
            case .statusCode(let response):
                switch response.statusCode {
                case 400:
                    let error = SignupError.fieldsError
                    return SignupResult.errored(error: error)
                case 403:
                    let error = SignupError.emailExists
                    return SignupResult.errored(error: error)
                default:
                    let error = SignupError.serverError
                    return SignupResult.errored(error: error)
                }
            default:
                break
            }
        }
        return SignupResult.errored(error: SignupError.serverError)
    }

    private static func mapLoginErrorToLoginResult(error: Swift.Error) -> LoginResult {
        if let error = error as? Moya.Error {
            switch error {
            case .statusCode(let response):
                switch response.statusCode {
                case 401:
                    return LoginResult.error(error: LoginError.passwordIncorrect)
                case 404:
                    return LoginResult.error(error: LoginError.emailNotFound)
                default:
                    return LoginResult.error(error: LoginError.other)
                }
            default:
                break
            }
        }
        return LoginResult.error(error: LoginError.other)
    }

}
