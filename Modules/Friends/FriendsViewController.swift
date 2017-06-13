//
//  FriendsViewController.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import RxCocoa
import RxDataSources

class FriendsViewController: BaseViewController {

    typealias DataSourceType = RxTableViewSectionedAnimatedDataSource<FriendsSectionModel>
    let disposeBag = DisposeBag()
    var viewModel: FriendsViewModel!

    @IBOutlet weak var tablesContainerView: UIView!

    let tableView = UITableView()
    let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)

    fileprivate let searchQuerySubject = ReplaySubject<String>.create(bufferSize: 0)
    var sections: Driver<[FriendsSectionModel]>!

    let dataSource = DataSourceType()

    override func viewDidLoad() {
        assert(viewModel != nil)
        super.viewDidLoad()
        setupTableView()

        sections = Driver.combineLatest(viewModel.searchUserResults, viewModel.users) { (searchResults, added) -> [FriendsSectionModel] in

            return [
                FriendsSectionModel(
                    model: AddFriendsSection.addCell,
                    items: [AddFriendsModel.add]
                ),
                FriendsSectionModel(
                    model: AddFriendsSection.searchResults,
                    items: searchResults.map { AddFriendsModel.searchResult($0) } + [AddFriendsModel.spacerCell]
                ),
                FriendsSectionModel(
                    model: AddFriendsSection.addedFriends,
                    items: added.map { AddFriendsModel.addedFriend($0) }
                )
            ]
        }

        sections.asObservable()
            .bindTo(tableView.rx.items(dataSource:dataSource))
            .addDisposableTo(disposeBag)

        dataSource.configureCell =  { [weak self] ds, tableView, indexPath, model -> UITableViewCell in
            guard let view = self else { return UITableViewCell() }
            return view.configureCell(tableView, at: indexPath, with: model)
        }

        navigationItem.title = "Add friends".uppercased()
        navigationItem.rightBarButtonItem = doneButton
    }

    fileprivate func configureCell(
    _ tableView: UITableView,
      at indexPath: IndexPath,
        with model: AddFriendsModel) -> UITableViewCell
    {
        switch model {
        case .add:
            return dequeueAddCell(tableView)
        case .addedFriend(let user):
            return dequeueUserCell(tableView, user: user, isAdded: true)
        case .searchResult(let user):
            return dequeueUserCell(tableView, user: user, isAdded: false)
        case .spacerCell:
            return dequeueSpacerCell(tableView)
        }
    }

    fileprivate func dequeueAddCell(_ tableView: UITableView) -> UITableViewCell {
        let addCell = tableView.dequeueReusableCell(withIdentifier: AddMorePeopleCell.className) as! AddMorePeopleCell
        addCell.disposeBag = DisposeBag()

        viewModel.emptySearch.drive(onNext: {
            addCell.queryTextField.text = ""
        }).addDisposableTo(addCell.disposeBag)

        addCell.queryTextField.rx.text.orEmpty.bindTo(searchQuerySubject).addDisposableTo(addCell.disposeBag)
        return addCell
    }

    fileprivate func dequeueUserCell(_ tableView: UITableView, user: User, isAdded: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddFriendResultCell.className) as! AddFriendResultCell
        cell.disposeBag = DisposeBag()

        cell.user.onNext(user)
        cell.isAdded = isAdded

        isUserFirst(user)
            .drive(onNext: { cell.isFirst.value = $0 })
            .addDisposableTo(cell.disposeBag)

        isUserLast(user)
            .drive(onNext: { cell.isLast.value = $0 })
            .addDisposableTo(cell.disposeBag)

        return cell
    }

    fileprivate func dequeueSpacerCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)
        cell?.contentView.backgroundColor = UIColor.bsktWhiteColor()
        return cell ?? UITableViewCell()
    }

    fileprivate func isUserFirst(_ model: User) -> Driver<Bool> {
        return Driver.combineLatest(viewModel.searchUserResults, viewModel.users) { (searchResults, added) -> Bool in
            return
                model.identity == searchResults.first?.identity ||
                model.identity == added.first?.identity
        }
    }

    fileprivate func isUserLast(_ model: User) -> Driver<Bool> {
        return Driver.combineLatest(viewModel.searchUserResults, viewModel.users) { (searchResults, added) -> Bool in
            return
                model.identity == searchResults.last?.identity ||
                model.identity == added.last?.identity
        }
    }

    fileprivate func setupTableView() {
        tablesContainerView.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.registerCellWithSameNamedNib(AddMorePeopleCell.self)
        tableView.registerCellWithSameNamedNib(AddFriendResultCell.self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)

        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.bsktWhiteColor()
    }
}

extension FriendsViewController: UITableViewDelegate {
    func addFriendModelAt(_ indexPath: IndexPath) -> AddFriendsModel? {
        return try? tableView.rx.model(at: indexPath) as AddFriendsModel
    }

    func isSpacerIn(_ tableView: UITableView, at indexPath: IndexPath) -> Bool {
        if let model: AddFriendsModel  = try? tableView.rx.model(at: indexPath) {
            switch model {
            case .spacerCell: return true
            default: return false
            }
        }
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isSpacerIn(tableView, at: indexPath) ? 32 : 64
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let model = addFriendModelAt(indexPath) {
            switch model {
            case .searchResult: return true
            default: return false
            }
        }
        return false
    }
}

extension FriendsViewController {
    var events: Driver<FriendsEvent> {
        return rxViewDidLoad.asDriver(onErrorJustReturn: ()).flatMap { [weak self] _ -> Driver<FriendsEvent> in
            guard let view = self else { return Driver.empty() }
            let searchChanged = view.searchQuerySubject
                .asDriver(onErrorJustReturn: "")
                .map { FriendsEvent.searchTextChanged($0) }

            let cellTapped = view.tableView
                .rx.modelSelected(AddFriendsModel.self)
                .map { $0 }

            let searchTap = cellTapped
                .mapAndFilterSearchTap()
                .map { FriendsEvent.addUser($0) }
                .asDriver(onErrorJustReturn: .error)

            let doneTapped = view.doneButton.rx.tap
                .map { FriendsEvent.doneTapped }
                .asDriver(onErrorJustReturn: .error)

            let viewWillAppear = view.rxViewWillAppear
                .map { FriendsEvent.viewWillAppear }
                .asDriver(onErrorJustReturn: .error)

            let merged = Driver.of(searchChanged, searchTap, doneTapped, viewWillAppear).merge()
            return merged
        }
    }
}

