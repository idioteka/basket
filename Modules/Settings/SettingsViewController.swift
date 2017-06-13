//
//  SettingsViewController.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import AERecord

class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    var viewModel: SettingsViewModel!

    typealias RxSettingsSection = AnimatableSectionModel<String, SettingsItem>

    let SettingsCellIdentifier = "SettingsCellIdentifier"
    let SettingsHeaderIdentifier = "SettingsHeaderIdentifier"
    let SettingsFooterIdentifier = "SettingsFooterIdentifier"

    var settingsItemSelected: Driver<SettingsItem> {
        return rxViewDidLoad.asDriver(onErrorJustReturn: ()).flatMap { [weak self] in
            guard let tableView = self?.tableView else { return Driver.empty() }
            return tableView.rx.modelSelected(SettingsItem.self).asDriver().map { $0 }
        }
    }

    let ds = RxTableViewSectionedAnimatedDataSource<RxSettingsSection>()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        navigationItem.title = "Settings".uppercased()

        setupTableView()

        let sections = viewModel.settingsSections.map { (sections) -> [RxSettingsSection] in
            return sections.map { RxSettingsSection(model: $0.title, items: $0.items) }
        }

        ds.configureCell = { ds, tv, ip, settingsItem in
            let cell = tv.dequeueReusableCell(withIdentifier: "SettingsCellIdentifier", for: ip) as! SettingsTableViewCell
            cell.populate(settingsItem)
            cell.selectionStyle = .none
            return cell
        }

        sections.asObservable()
            .bindTo(tableView.rx.items(dataSource:ds))
            .addDisposableTo(disposeBag)
    }

    func setupTableView() {
        tableView.backgroundColor = UIColor.bsktWhiteColor()
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsCellIdentifier)
        tableView.register(UINib(nibName: "SettingsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsHeaderIdentifier)
        tableView.register(UINib(nibName: "SettingsSectionFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsFooterIdentifier)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let text = viewModel.sections[section].footerText {
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsFooterIdentifier) as! SettingsSectionFooterView
            footerView.populate(text)
            return footerView
        } else {
            return UIView(frame: CGRect.zero)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let _ = viewModel.sections[section].footerText {
            return 50
        } else {
            return 0.001
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = viewModel.sections[section].title
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsHeaderIdentifier) as! SettingsSectionHeaderView
        headerView.populate(title)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
