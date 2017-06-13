//
//  BasketSplitBillViewController.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias BillSection = AnimatableSectionModel<String, BillItem>

class BasketSplitBillViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var tableViewHeader: SplitBillHeaderView = Bundle.main.loadNibNamed("SplitBillHeaderView", owner: nil, options: nil)![0] as! SplitBillHeaderView

    var viewModel: BasketSplitBillViewModel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(viewModel != nil)

        setupTableView()

        let billItems = viewModel.billItems.filterSuccess()

        let dataSource = RxTableViewSectionedAnimatedDataSource<BillSection>()

        dataSource.configureCell = { ds, tv, ip, billItem in
            let cell = tv.dequeueReusableCell(withIdentifier: SplitBillTableViewCell.className, for: ip) as! SplitBillTableViewCell

            cell.populate(billItem)
            return cell
        }

        let sections = billItems.map { [BillSection(model: "Section", items: $0)] }

        sections.asObservable().bindTo(
            tableView.rx.items(dataSource:dataSource)
        ).addDisposableTo(disposeBag)

        viewModel.basket.filterSuccess().map { (basket) in
            return basket.bill?.total
        }.startWith(viewModel.totalAmountSpent)
        .drive(onNext: { [weak self] amount in
            self?.tableViewHeader.populate(amount)
        })
        .addDisposableTo(disposeBag)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.registerCellWithSameNamedNib(SplitBillTableViewCell.self)
        tableView.backgroundColor = UIColor.bsktWhiteColor()
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 85)
        tableView.tableHeaderView = tableViewHeader
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let header = tableView.tableHeaderView
        header?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 85)
        tableView.tableHeaderView = header
    }

    deinit {
        print("Split Bill did deinit")
    }
}

extension BasketSplitBillViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
