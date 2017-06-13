//
//  CreateBasketRouter.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateBasketRouter: BaseRouter {
    let disposeBag = DisposeBag()
    let networking: AuthorizedNetworking

    var savedFriendsVM: NewBasketFriendsViewModel?
    var savedFriendsVC: FriendsViewController?

    init(networking: AuthorizedNetworking) {
        self.networking = networking
    }

    func startIn(_ navigationViewController: UINavigationController) -> Driver<CreateBasketResult> {
        let viewController = CreateBasketViewController.initFromSameNamedNib()
        addViewController(viewController)
        let firstViewModel = CreateBasketViewModel(events: viewController.event)
        viewController.viewModel = firstViewModel

        let nvc = UINavigationController(rootViewController: viewController)
        navigationViewController.present(nvc, animated: true, completion: nil)

        let cancelTapped = viewController.event.filter { $0 == .cancelTapped }.mapVoid()
        let nextTapped = viewController.event.filter { $0 == .nextTapped }.mapVoid()

        let secondStepCompleted = nextTapped.flatMapLatest { [weak self, unowned nvc] () -> Driver<()> in
            guard let router = self else { return Driver.empty() }
            return router.goToSecondStepWith(firstViewModel.data, inNavigationController: nvc)
        }

        let canceled = cancelTapped.map { CreateBasketResult.canceled }
        let completed = secondStepCompleted.map { CreateBasketResult.completed }

        canceled.asObservable().take(1).subscribe(onNext: { [weak self] _ in
            self?.savedFriendsVC = nil
        }).addDisposableTo(disposeBag)

        return Driver.of(canceled, completed).merge()
    }

    func goToSecondStepWith(_ data: Driver<CreateBasketFirstStepData>, inNavigationController: UINavigationController) -> Driver<()> {
        let friendsVCC: FriendsViewController
        let friendsVM: NewBasketFriendsViewModel
        if let savedVC = savedFriendsVC, let savedVM = savedFriendsVM {
            friendsVCC = savedVC
            friendsVM = savedVM
        } else {
            friendsVCC = FriendsViewController.initFromSameNamedNib()
            friendsVM = NewBasketFriendsViewModel(events: friendsVCC.events, searchService: SearchService(networking: networking), createService: CreateBasketService(networking: networking), firstStepData: data)
            friendsVCC.viewModel = friendsVM
            addViewController(friendsVCC)
            savedFriendsVC = friendsVCC
            savedFriendsVM = friendsVM
        }

        inNavigationController.pushViewController(friendsVCC, animated: true)

        return friendsVM.completed
    }

    deinit {
        print("create router did deinit")
    }
}

enum CreateBasketResult {
    case completed
    case canceled
    case error(error: Error)
}
