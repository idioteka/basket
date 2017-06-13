//
//  ActivityViewController.swift
//  Basket
//
//  Created by Mario Radonic on 01/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias ActivitySection = AnimatableSectionModel<String, BasketActivity>

class ActivityViewController: BaseViewController {

    var viewModel: ActivityViewModel!

    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        let activities = viewModel.activities.filterSuccess()

        let dataSource = RxTableViewSectionedAnimatedDataSource<ActivitySection>()

        dataSource.configureCell = { ds, tv, ip, activity in
            let cell = tv.dequeueReusableCell(withIdentifier: ActivityTableViewCell.className, for: ip) as! ActivityTableViewCell

            cell.populate(activity)
            return cell
        }

        let sections = activities.map { [ActivitySection(model: "Section", items: $0)] }

        sections.asObservable().bindTo(
            tableView.rx.items(dataSource:dataSource)
            ).addDisposableTo(disposeBag)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.registerCellWithSameNamedNib(ActivityTableViewCell.self)
        tableView.backgroundColor = UIColor.bsktWhiteColor()
    }

    deinit {
        print("Activity did deinit")
    }
}

extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
