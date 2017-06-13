//
//  SettingsRouter.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsRouter: BaseRouter {
    
    let disposeBag = DisposeBag()
    
    let authService: AuthenticationService
    let userService: UserService
    let userId: Int
    
    init(authService: AuthenticationService, userService: UserService, userId: Int, settingsItem: SettingsItem) {
        self.authService = authService
        self.userService = userService
        self.userId = userId
    }
    
    func showIn(_ navigationController: UINavigationController) {
        let editProfileVc = EditProfileViewController.initFromSameNamedNib()
        editProfileVc.rxViewDidLoad.subscribe(onNext: { [weak self] in
            guard let router = self else {
                return
            }
            let editProfileVM = EditProfileViewModel(
                events: editProfileVc.events,
                inputs: editProfileVc.outputs,
                authService: router.authService,
                userService: router.userService,
                userId: router.userId
            )
            editProfileVc.viewModel = editProfileVM
        }).addDisposableTo(disposeBag)
        addViewController(editProfileVc)
        navigationController.pushViewController(editProfileVc, animated: true)
    }
}

