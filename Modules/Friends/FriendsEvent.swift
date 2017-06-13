//
//  FriendsEvent.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FriendsEventType {
    
}
enum FriendsEvent {
    case searchTextChanged(String)
    case addUser(User)
    case doneTapped
    case error
    case viewWillAppear

    var isSearch: Bool {
        switch self {
        case .searchTextChanged: return true
        default: return false
        }
    }
}


extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E ==  FriendsEvent {
    func filterSearch() -> Driver<String> {
        return self.flatMap { ev -> Driver<String> in
            switch ev {
            case .searchTextChanged(let str):
                return Driver.just(str)
            default:
                return Driver.empty()
            }
        }
    }

    func filterAddUser() -> Driver<User> {
        return self.flatMap { ev -> Driver<User> in
            switch ev {
            case .addUser(let user):
                return Driver.just(user)
            default:
                return Driver.empty()
            }
        }
    }

    func filterDoneTapped() -> Driver<()> {
        return self.flatMap { ev -> Driver<()> in
            switch ev {
            case .doneTapped:
                return Driver.just()
            default:
                return Driver.empty()
            }
        }
    }

    func filterViewWillAppear() -> Driver<()> {
        return self.flatMap { ev -> Driver<()> in
            switch ev {
            case .viewWillAppear:
                return Driver.just()
            default:
                return Driver.empty()
            }
        }
    }
}
