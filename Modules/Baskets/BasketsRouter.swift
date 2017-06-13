//
//  BasketsRouter.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa

class BasketsRouter: BaseRouter {

    let basketService: BasketService
    let userService: UserService
    let networking: AuthorizedNetworking
    let authService: AuthenticationService
    let userID: Int
    let disposeBag = DisposeBag()

    init(networking: AuthorizedNetworking, userID: Int, authService: AuthenticationService) {
        self.networking = networking
        self.userID = userID
        self.authService = authService

        basketService = BasketService(networking: networking)
        userService = UserService(networking: networking)
    }

    deinit {
        print("baskets router did deinit")
    }

    func startIn(_ window: UIWindow) {
        let navigationController = UINavigationController()
        startIn(navigationController)
        window.rootViewController = navigationController
    }

    func startIn(_ navigationController: UINavigationController) {
        let firstBasketViewController = FirstBasketViewController.initFromSameNamedNib()

        let firstBasketViewontrollerNavigationController = UINavigationController(rootViewController: firstBasketViewController)
        firstBasketViewController.createBasketTapped.asDriver().drive(onNext: { [weak self] tapped in
            if tapped {
                self?.showCreateBasketInNavigationController(firstBasketViewontrollerNavigationController, withRootNavigationController: navigationController)
            }
        }).addDisposableTo(disposeBag)

        let basketsViewController = createNewBasketViewControllerWithFirstBasketViewController(firstBasketViewontrollerNavigationController)

        basketsViewController.basketSelected.drive(onNext: { [weak self] basketId in
            guard let router = self else { return }

            let mtr = MainTabBarRouter(basketService: router.basketService, networking: router.networking, basketId: basketId, userId: router.userID)

            mtr.showIn(navigationController)

        }).addDisposableTo(disposeBag)

        basketsViewController.settingsTapped
            .bindTo(showSettingsInNavigationController(navigationController))
            .addDisposableTo(disposeBag)

        // Create basket
        basketsViewController.addBasketTapped.drive(onNext: { [weak self] in
            self?.showCreateBasketInNavigationController(navigationController)
        }).addDisposableTo(disposeBag)

        navigationController.setViewControllers([basketsViewController], animated: true)
    }

    fileprivate func createNewBasketViewControllerWithFirstBasketViewController(_ navigationController: UINavigationController) -> BasketsViewController {
        let basketsViewController = BasketsViewController.initFromSameNamedNib()

        let rejectBasket = basketsViewController.rejectBasketTapped.flatMapLatest { [weak self] (basket) -> Observable<(BasketInvitationAction, Int)> in
            guard let router = self else {
                return Observable.empty()
            }
            return router.showReject(basketsViewController).map {
                ($0, basket)
            }
        }

        let acceptBasket = basketsViewController.acceptBasketTapped.map {
            (BasketInvitationAction.accept, $0)
        }

        let invitationAction = Observable.of(acceptBasket, rejectBasket).merge()

        let basketsListViewModel = BasketsListViewModel(
            basketService: basketService,
            userId: userID,
            invitationAction: invitationAction,
            viewAppear:  basketsViewController.rxViewWillAppear
        )

        addViewController(basketsViewController)

        basketsViewController.viewModel = basketsListViewModel

        basketsListViewModel.firstBasket.asObservable().subscribe(onNext: { isFirstBasket in
            if isFirstBasket {
                basketsViewController.present(navigationController, animated: false, completion: nil)
            }
        }).addDisposableTo(disposeBag)

        return basketsViewController
    }

    func showSettingsInNavigationController(_ navigationController: UINavigationController) -> AnyObserver<Void> {
        return UIBindingObserver(UIElement: navigationController, binding: { [weak self] (nvc, vojd) in
            guard let router = self else { return }
            let settingsVC = SettingsViewController.initFromSameNamedNib()

            settingsVC.settingsItemSelected.drive(onNext: { [weak self] settingsItem in
                switch settingsItem.type {
                case .navigationItem:
                    let settingsRouter = SettingsRouter(authService: router.authService, userService: router.userService, userId: router.userID, settingsItem: settingsItem)
                    settingsRouter.showIn(navigationController)
                case .logout:
                    self?.authService.logout()
                default:
                    break
                }
            }).addDisposableTo(router.disposeBag)

            settingsVC.rxViewDidLoad.subscribe(onNext: {
                let settingsVM = SettingsViewModel(authService: router.authService, userService: router.userService, userId: router.userID)
                settingsVC.viewModel = settingsVM
            }).addDisposableTo(router.disposeBag)
            router.addViewController(settingsVC)
            nvc.pushViewController(settingsVC, animated: true)
        }).asObserver()
    }

    func showEditProfileInNavigationController(_ navigationController: UINavigationController) -> AnyObserver<Void> {
        return UIBindingObserver(UIElement: navigationController, binding: { [weak self] (nvc, vojd) in
            guard let router = self else { return }
            let editProfileVc = EditProfileViewController.initFromSameNamedNib()
            editProfileVc.rxViewDidLoad.subscribe(onNext: {
                let editProfileVM = EditProfileViewModel(events: editProfileVc.events, inputs: editProfileVc.outputs, authService: router.authService, userService: router.userService, userId: router.userID)
                editProfileVc.viewModel = editProfileVM
                }).addDisposableTo(router.disposeBag)
            router.addViewController(editProfileVc)
            nvc.pushViewController(editProfileVc, animated: true)
        }).asObserver()
    }

    func showReject(_ vc: UIViewController) -> Observable<BasketInvitationAction> {

        return Observable.create({ (observer) -> Disposable in
            let actionSheet = UIAlertController(title: "Decline this basket?", message: "Are you sure", preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                observer.onCompleted()
            })
            actionSheet.addAction(cancelAction)
            let rejectAction = UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
                observer.onNext(.reject)
                observer.onCompleted()
            })
            actionSheet.addAction(rejectAction)
            let rejectAndBlockAction = UIAlertAction(title: "Reject & block", style: .destructive, handler: { _ in
                observer.onNext(.rejectAndBlock)
                observer.onCompleted()
            })
            actionSheet.addAction(rejectAndBlockAction)

            vc.present(actionSheet, animated: true, completion: nil)

            return Disposables.create()
        })

    }

    func showCreateBasketInNavigationController(_ navigationController: UINavigationController, withRootNavigationController rootNVC:UINavigationController) {
        let createRouter = CreateBasketRouter(networking: networking)
        createRouter.startIn(navigationController).drive(onNext: { [weak navigationController] (result) in
            switch result {
            case .canceled:
                navigationController?.dismiss(animated: true, completion: nil)
            case .completed:
                navigationController?.dismiss(animated: true, completion: {
                    rootNVC.dismiss(animated: false, completion: nil)
                })
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }

    func showCreateBasketInNavigationController(_ navigationController: UINavigationController) {
        let createRouter = CreateBasketRouter(networking: networking)
        createRouter.startIn(navigationController).drive(onNext: { [weak navigationController] (result) in
            switch result {
            case .canceled, .completed:
                navigationController?.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }

}

enum BasketInvitationAction {
    case accept
    case reject
    case rejectAndBlock
}
