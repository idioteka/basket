//
//  LandingViewModel.swift
//  Basket
//
//  Created by Josip Maric on 20/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import FBSDKLoginKit

class LandingViewModel: FacebookLoginViewModel {
    let disposeBag = DisposeBag()
    let facebookLoginResult: Driver<FBSDKLoginManagerLoginResult?>
    let authenticationService: AuthenticationService

    init(facebookLoginResult: Driver<FBSDKLoginManagerLoginResult?>, authenticationService: AuthenticationService) {
        self.facebookLoginResult = facebookLoginResult
        self.authenticationService = authenticationService
    }
}

protocol FacebookLoginViewModel: class {
    var authenticationService: AuthenticationService { get }
    var facebookLoginResult: Driver<FBSDKLoginManagerLoginResult?> { get }
}

extension FacebookLoginViewModel {
    var facebookBasketLoginResult: Driver<LoginResult> {
        return facebookLoginResult.flatMapLatest { [weak self] result in
            guard let result = result else {
                return Driver.just(LoginResult.error(error: LoginError.other))
            }
            return self?.authenticationService.loginWithFacebookResult(result)
                .catchErrorJustReturn(LoginResult.error(error: LoginError.other))
                .asDriver(onErrorJustReturn:LoginResult.error(error: LoginError.other)) ?? Driver.empty()
        }
    }

    var facebookError: Driver<LoginError> {
        return facebookBasketLoginResult.mapAndFilterNil { (result) -> LoginError? in
            switch result {
            case .error(let error): return error
            default: return nil
            }
        }
    }
}
