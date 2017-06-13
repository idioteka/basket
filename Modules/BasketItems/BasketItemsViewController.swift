//
//  BasketItemsViewController.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MGSwipeTableCell

typealias ItemsSection = AnimatableSectionModel<String, ItemCellViewModel>

class BasketItemsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyScreenView: UIView!
    @IBOutlet weak var instructionTitleLabel: UILabel!
    @IBOutlet weak var instructionSubtitleLabel: UILabel!

    var viewModel: BasketItemsViewModel!

    var tableViewHeader: BasketItemsTableViewHeader = Bundle.main.loadNibNamed("BasketItemsTableViewHeader", owner: nil, options: nil)![0] as! BasketItemsTableViewHeader

    let ItemCellIdentifier = "ItemTableViewCell"
    let disposeBag = DisposeBag()
    let refreshControl = UIRefreshControl()

    fileprivate let actionSubject = PublishSubject<(BasketItemAction, Int)>()
    var itemAction: ControlEvent<(BasketItemAction, Int)> {
        return ControlEvent(events: actionSubject)
    }

    var addItem: Driver<String> {
        return rxViewDidLoad.asDriver(onErrorJustReturn: ()).flatMap { [weak self] () -> Driver<String> in
            guard let view = self else { return Driver.empty() }
            let tap = view.tableViewHeader.tap
            return tap.withLatestFrom(view.tableViewHeader.text).asDriver(onErrorJustReturn: "")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)

        setupTableView()
        setupEmptyScreenPlaceholder()

        let itemCellViewModels = viewModel.itemCellViewModels.filterSuccess()

        let datasource = RxTableViewSectionedAnimatedDataSource<ItemsSection>()

        datasource.configureCell = { [weak self] ds, tv, ip, itemViewModel in
            guard let view = self else { return UITableViewCell() }
            let cell = tv.dequeueReusableCell(withIdentifier: view.ItemCellIdentifier, for: ip) as! ItemTableViewCell

            cell.populate(itemViewModel)

            weak var innerView = view
            cell.itemAction
                .takeUntil(cell.rxReused)
                .map { return ($0, itemViewModel.itemId) }
                .bindNext({
                    innerView?.actionSubject.onNext($0)
                })
                .addDisposableTo(view.disposeBag)

            return cell
        }

        viewModel.clearNewItemField.map { "" }.asObservable().bindTo(tableViewHeader.text).addDisposableTo(disposeBag)

        viewModel.hideEmptyScreen.asObservable().bindTo(emptyScreenView.rx.isHidden).addDisposableTo(disposeBag)

        viewModel.hideAddItem.asObservable().bindTo(tableViewHeader.rx.isHidden).addDisposableTo(disposeBag)

        viewModel.hideAddItem.asObservable().subscribe(onNext: { [weak self] (hidden) in
            if let view = self?.view, !hidden {
                self?.tableViewHeader.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 64)
                self?.tableView.tableHeaderView = self?.tableViewHeader
            } else {
                self?.tableView.tableHeaderView = nil
            }
        }).addDisposableTo(disposeBag)

        let sections = itemCellViewModels.map { [ItemsSection(model: "Section", items: $0)] }
        sections.asObservable().bindTo(
            tableView.rx.items(dataSource:datasource)
        ).addDisposableTo(disposeBag)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: ItemCellIdentifier)
        tableView.backgroundColor = UIColor.bsktWhiteColor()

        tableView.addSubview(refreshControl)
        refreshControl.rx.controlEvent(UIControlEvents.valueChanged).map { [weak self] _ -> Bool in
            return self?.refreshControl.isRefreshing ?? false
        }.filter { $0 }.mapVoid().bindNext(viewModel.refresh.onNext).addDisposableTo(disposeBag)

        viewModel.refreshing
            .drive(refreshControl.rx.isRefreshing)
            .addDisposableTo(disposeBag)
    }

    func setupEmptyScreenPlaceholder() {
        instructionTitleLabel.text = "Tap on the + icon to add items to your basket."
        instructionTitleLabel.font = UIFont.bsktBigMediumFont()
        instructionTitleLabel.textColor = UIColor.bsktWarmGreyColor()

        instructionSubtitleLabel.text = "Once you’ve added enough, swipe item to the left to reserve it, buy it, or delete it."
        instructionSubtitleLabel.font = UIFont.bsktBigMediumFont()
        instructionSubtitleLabel.textColor = UIColor.bsktWarmGreyColor()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let header = tableView.tableHeaderView
        header?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
        tableView.tableHeaderView = header
    }

    deinit {
        print("Items did deinit")
    }
}

extension BasketItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

