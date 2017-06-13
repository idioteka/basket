//
//  MainTabBarRouter.swift
//  Basket
//
//  Created by Mario Radonic on 12/04/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import MapKit

class MainTabBarRouter: BaseRouter {

    let networking: AuthorizedNetworking
    let basketService: BasketService
    let basketId: Int
    let userId: Int

    let disposeBag = DisposeBag()

    init(basketService: BasketService, networking: AuthorizedNetworking, basketId: Int, userId: Int) {
        self.basketService = basketService
        self.basketId = basketId
        self.userId = userId
        self.networking = networking
    }

    func showIn(_ navigationController: UINavigationController) {
        guard let basket = Basket.first(with: "id", value: basketId) else {
            return
        }

        let mainTabBarViewModel = MainTabBarViewModel(basketService: basketService, basketId: basketId)
        let imageName: String? = basket.isLocked ? "navigationBarLock" : nil
        let navigationTitleContent = NavigationTitleContent(title: basket.name ?? "", subtitle: basket.basketSummary, imageName: imageName)
        let mainTabBarController = MainTabBarController(viewModel: mainTabBarViewModel, navigationTitleContent: navigationTitleContent)

        let basketItemsViewController = BasketItemsViewController.initFromSameNamedNib()
        addViewController(basketItemsViewController)

        setTabBarItem(.items, toViewController: basketItemsViewController)

        let titleEdited = basketItemsViewController.itemAction.filter { (action, id) -> Bool in
            return action.isEdit
        }.map { _, id in return id }.flatMapLatest { [weak self, unowned basketItemsViewController] id -> Observable<(BasketItemAction, Int)> in
            guard let router = self else {
                return Observable.empty()
            }
            return router.showEditAlertIn(basketItemsViewController, withId: id)
        }.asDriver(onErrorJustReturn: (BasketItemAction.edit(""), 0))

        let itemBought = basketItemsViewController.itemAction.filter { (action, id) -> Bool in
            return action.isBuy
            }.map { _, id in return id }.flatMapLatest { [weak self, unowned basketItemsViewController] id -> Observable<(BasketItemAction, Int)> in
                guard let router = self else {
                    return Observable.empty()
                }
                return router.showBuyAlertIn(basketItemsViewController, withId: id)
            }.asDriver(onErrorJustReturn: (BasketItemAction.buy(nil), 0))

        let otherItemAction = basketItemsViewController.itemAction.filter { (action, id) -> Bool in
            return !action.isBuy && !action.isEdit
        }.asDriver(onErrorJustReturn: (BasketItemAction.unreserve, 0))

        let itemAction = Observable.of(titleEdited, itemBought, otherItemAction).merge()

        let basketItemsViewModel = BasketItemsViewModel(basketService: basketService, basketId: basketId, userId: userId, itemAction: itemAction, addItem: basketItemsViewController.addItem)
        basketItemsViewController.viewModel = basketItemsViewModel

        let friendsVC = FriendsViewController.initFromSameNamedNib()
        let searchService = SearchService(networking: networking)
        let friendsVM = ExistingBasketFriendsViewModel(basketId: basketId, events: friendsVC.events, searchService: searchService, basketService: basketService)

        friendsVC.viewModel = friendsVM
        setTabBarItem(.people, toViewController: friendsVC)

        let activityViewController = ActivityViewController.initFromSameNamedNib()
        let activityViewModel = ActivityViewModel(basketService: basketService, basketId: basketId, userId: userId, viewWillAppear: activityViewController.rxViewWillAppear)
        activityViewController.viewModel = activityViewModel
        setTabBarItem(.activity, toViewController: activityViewController)

        let basketSplitBillViewController = BasketSplitBillViewController.initFromSameNamedNib()
        let basketSplitBillViewModel = BasketSplitBillViewModel(basketService: basketService, basketId: basketId, userId: userId, viewWillAppear: basketSplitBillViewController.rxViewWillAppear)
        basketSplitBillViewController.viewModel = basketSplitBillViewModel
        setTabBarItem(.splitBill, toViewController: basketSplitBillViewController)

        let basketDetailsViewController = BasketDetailsViewController.initFromSameNamedNib()

        basketDetailsViewController.directionsTapped.subscribe(onNext: { [weak self] (coordinates, address) in
            guard let router = self else { return }

            router.showMapWithCoordinates(coordinates, address: address)
        }).addDisposableTo(disposeBag)

        let leaveBasket = basketDetailsViewController.leaveBasketTapped.flatMapLatest { [weak self] () -> Observable<()> in
            guard let router = self else {
                return Observable.empty()
            }
            return router.showLeaveBasket(basketDetailsViewController)
        }

        let basketDetailsViewModel = BasketDetailsViewModel(basketService: basketService, basketId: basketId, userId: userId, leaveBasket: leaveBasket)

        basketDetailsViewModel.userLeftBasket.drive(onNext: { (success) in
            navigationController.popViewController(animated: true)
        }).addDisposableTo(disposeBag)

        basketDetailsViewController.viewModel = basketDetailsViewModel
        setTabBarItem(.details, toViewController: basketDetailsViewController)

        mainTabBarController.setViewControllers([basketItemsViewController, friendsVC, activityViewController, basketDetailsViewController, basketSplitBillViewController], animated: true)
        navigationController.pushViewController(mainTabBarController, animated: true)
    }

    fileprivate func setTabBarItem(_ tabBar: BasketTabBars, toViewController viewController: BaseViewController) {
        viewController.tabBarItem = UITabBarItem(title: tabBar.title, image: UIImage(named: tabBar.imageName)?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: tabBar.selectedImageName)?.withRenderingMode(.alwaysOriginal))
    }

    func showBuyAlertIn(_ vc: UIViewController, withId: Int) -> Observable<(BasketItemAction, Int)> {
        weak var viewController = vc
        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: "Enter price", message: nil, preferredStyle: .alert)

            alert.addTextField(configurationHandler: {
                textField in
                textField.placeholder = "Price"
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                observer.onCompleted()
            })

            alert.addAction(cancelAction)

            let editedAction = UIAlertAction(title: "Buy", style: .default, handler: { _ in
                if
                    let textFields = alert.textFields,
                    let text = textFields[0].text {
                        observer.onNext((BasketItemAction.buy(Double(text)), withId))
                        observer.onCompleted()
                } else {
                    observer.onCompleted()
                }
            })
            alert.addAction(editedAction)

            viewController?.present(alert, animated: true, completion: nil)

            return Disposables.create()
        })
    }

    func showEditAlertIn(_ vc: UIViewController, withId: Int) -> Observable<(BasketItemAction, Int)> {
        weak var vc = vc
        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: "Enter new item title", message: nil, preferredStyle: .alert)

            alert.addTextField(configurationHandler: {
                textField in
                textField.placeholder = "Item title"
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                observer.onCompleted()
            })

            alert.addAction(cancelAction)

            let editedAction = UIAlertAction(title: "Change Title", style: .default, handler: { _ in
                if let textFields = alert.textFields, let text = textFields[0].text {
                    observer.onNext((BasketItemAction.edit(text), withId))
                    observer.onCompleted()
                } else {
                    observer.onCompleted()
                }
            })
            alert.addAction(editedAction)

            vc?.present(alert, animated: true, completion: nil)

            return Disposables.create()
        })
    }

    func showMapWithCoordinates(_ location: (longitude: Double, latitude: Double)?, address: String?) {
        guard
            let location = location,
            let address = address
        else {
            print("no location or address")
            return
        }
        let coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = address
        mapItem.openInMaps(launchOptions: nil)
    }

    func showLeaveBasket(_ vc: UIViewController) -> Observable<Void> {

        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: "Leave this basket?", message: "Are you sure", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                observer.onCompleted()
            })
            alert.addAction(cancelAction)
            let leaveAction = UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
                observer.onNext()
                observer.onCompleted()
            })
            alert.addAction(leaveAction)

            vc.present(alert, animated: true, completion: nil)

            return Disposables.create()
        })

    }
}
