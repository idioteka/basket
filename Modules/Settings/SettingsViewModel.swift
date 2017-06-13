//
//  SettingsViewModel.swift
//  Basket
//
//  Created by Josip Maric on 22/05/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import AERecord
import RxDataSources

enum SettingsItemType {
    case navigationItem, `switch`, logout

    var isCheveronHidden: Bool {
        switch self {
        case .navigationItem:
            return false
        default:
            return true
        }
    }

    var isSwitchHidden: Bool {
        switch self {
        case .switch:
            return false
        default:
            return true
        }
    }
}

struct SettingsItem {
    let title: String
    let type: SettingsItemType
}

struct SettingsSection {
    let title: String
    let items: [SettingsItem]
    let footerText: String?
}

class SettingsViewModel {
    let userId: Int

    let sections: [SettingsSection]

    let settingsSections: Driver<[SettingsSection]>

    init(authService: AuthenticationService, userService: UserService, userId: Int) {
        self.userId = userId

        let databaseBaskets: Observable<[Basket]> = AERecord.Context.default.rx_entities()

        let a = [
            SettingsSection(title: "MY ACCOUNT", items: [
                SettingsItem(title: "Edit Profile", type: .navigationItem),
                SettingsItem(title: "Change Password 🔑", type: .navigationItem),
                SettingsItem(title: "Archived Basket", type: .navigationItem),
                SettingsItem(title: "Blocked People", type: .navigationItem),
                SettingsItem(title: "Log Out", type: .logout)
                ], footerText: nil),
            SettingsSection(title: "NOTIFICATIONS", items: [
                SettingsItem(title: "When someone invites me to basket", type: .switch),
                SettingsItem(title: "When a basket I'm in is archived", type: .switch)
                ], footerText: "Pro tip: You can turn on/off notifications for a single  basket in the Settings screen of that basket."),
            SettingsSection(title: "MORE", items: [
                SettingsItem(title: "Help", type: .navigationItem),
                SettingsItem(title: "Terms of Service", type: .navigationItem),
                SettingsItem(title: "Report a Problem", type: .navigationItem)
                ], footerText: nil)
        ]

        sections = a

        settingsSections = databaseBaskets.map { _ in a }.asDriver(onErrorJustReturn: [])

    }
}

extension SettingsItem: IdentifiableType, Equatable {
    var identity: Int {
        return title.hashValue
    }
}

func ==(lhs: SettingsItem, rhs: SettingsItem) -> Bool {
    return lhs.identity == rhs.identity
}

