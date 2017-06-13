//
//  BasketsViewController.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

import Moya
import RxSwift
import RxCocoa
import RxDataSources
import AERecord

typealias BasketsSection = AnimatableSectionModel<String, BasketViewModel>

class BasketsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel: BasketsListViewModel!
    let refreshControl = UIRefreshControl()

    let BasketsCellIdentifier = "BasketTableViewCell"
    let PendingBasketTableViewCellIdentifier = "PendingBasketTableViewCell"

    var addBasketTapped: Driver<()> {
        return addBarButtonItem.rx.tap.takeUntil(rx.deallocated).asDriver(onErrorJustReturn: ())
    }

    fileprivate let acceptBasketSubject = PublishSubject<Int>()
    var acceptBasketTapped: ControlEvent<Int> {
        return ControlEvent(events: acceptBasketSubject.asObservable())
    }

    fileprivate let rejectBasketSubject = PublishSubject<Int>()
    var rejectBasketTapped: ControlEvent<Int> {
        return ControlEvent(events: rejectBasketSubject.asObservable())
    }

    var basketSelected: Driver<Int> {
        return rxViewDidLoad.asDriver(onErrorJustReturn: ()).flatMap { [weak self] in
            guard let tableView = self?.tableView else { return Driver.empty() }
            return tableView.rx.modelSelected(BasketViewModel.self).asDriver().map { $0.basketId }
        }
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

    fileprivate let settingsBarButtonItem = UIBarButtonItem(
        image: UIImage(named: "icNavbarSettings"),
        style: UIBarButtonItemStyle.plain,
        target: nil, action: nil)

    var settingsTapped: ControlEvent<Void> {
        return settingsBarButtonItem.rx.tap
    }

    let ds = RxTableViewSectionedAnimatedDataSource<BasketsSection>()

    override func viewDidLoad() {
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)

        super.viewDidLoad()
        assert(viewModel != nil)

        tableView.addSubview(refreshControl)

        viewModel.refreshing
            .drive(refreshControl.rx.isRefreshing)
            .addDisposableTo(disposeBag)

        _ = refreshControl.rx.controlEvent(UIControlEvents.valueChanged).map { [weak self] _ -> Bool in
            return self?.refreshControl.isRefreshing ?? false
        }.filter { $0 }.mapVoid().bindNext(viewModel.refreshBaskets.onNext)

        navigationItem.title = "Baskets".uppercased()
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.leftBarButtonItem = settingsBarButtonItem

        setupTableView()

        let sections = viewModel.baskets.map { baskets -> ([BasketViewModel], [BasketViewModel]) in
            switch baskets {
            case .success(let baskets):
                let pending = baskets.filter { $0.pending }
                let active = baskets.filter { !$0.pending }

                return (pending, active)
            default:
                return ([], [])
            }
        }.map {
            return [
                BasketsSection(model: "Pending", items: $0.0),
                BasketsSection(model: "Active", items: $0.1)
            ]
        }

        ds.configureCell = { [weak self] ds, tv, ip, basketViewModel in
            if basketViewModel.pending {
                let cell = tv.dequeueReusableCell(withIdentifier: "PendingBasketTableViewCell", for: ip) as! PendingBasketTableViewCell
                cell.viewModelSubject.onNext(basketViewModel)

                cell.reuseDisposeBag = DisposeBag()
                let accept = cell.acceptButton.rx.tap.map { basketViewModel.basketId }
                accept.bindTo(self!.acceptBasketSubject)
                    .addDisposableTo(cell.reuseDisposeBag)

                let reject = cell.declineButton.rx.tap.map { basketViewModel.basketId }
                reject.bindTo(self!.rejectBasketSubject)
                    .addDisposableTo(cell.reuseDisposeBag)

                return cell
            } else {
                let cell = tv.dequeueReusableCell(withIdentifier: "BasketTableViewCell", for: ip) as! BasketTableViewCell
                cell.viewModelSubject.onNext(basketViewModel)
                return cell
            }
        }

        sections.asObservable()
            .bindTo(tableView.rx.items(dataSource:ds))
            .addDisposableTo(disposeBag)
    }

    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "BasketTableViewCell", bundle: nil), forCellReuseIdentifier: BasketsCellIdentifier)
        tableView.register(UINib(nibName: "PendingBasketTableViewCell", bundle: nil), forCellReuseIdentifier: PendingBasketTableViewCellIdentifier)
    }

    deinit {
        print("Baskets VC did deinit")
    }

}

extension BasketsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath as NSIndexPath).section == 0 ? 172 : 74
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
