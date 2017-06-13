//
//  FriendsSectionModel.swift
//  Basket
//
//  Created by Mario Radonic on 4/24/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

typealias FriendsSectionModel = AnimatableSectionModel<AddFriendsSection, AddFriendsModel>

extension User: IdentifiableType {
    var identity : Int {
        return Int(self.id)
    }
}

enum AddFriendsSection: Int, IdentifiableType {
    case addCell
    case searchResults
    case addedFriends

    var identity: Int {
        return self.rawValue
    }
}

enum AddFriendsModel: IdentifiableType, Hashable {
    case add
    case searchResult(User)
    case addedFriend(User)
    case spacerCell

    var identity : Int {
        switch self {
        case .add:
            return -1
        case .spacerCell:
            return Int(arc4random())
        case .searchResult(let user):
            return Int(user.id)
        case .addedFriend(let user):
            return Int(user.id)
        }
    }

    var hashValue: Int {
        return identity
    }
}

func == (lhs: AddFriendsModel, rhs: AddFriendsModel) -> Bool {
    switch (lhs, rhs) {
    case (.add, .add):
        return true
    case (.searchResult(let lUser), .addedFriend(let rUser)):
        return lUser.id == rUser.id
    case (.addedFriend(let lUser), .addedFriend(let rUser)):
        return lUser.id == rUser.id
    case (.addedFriend(let lUser), .searchResult(let rUser)):
        return lUser.id == rUser.id
    case (.searchResult(let lUser), .searchResult(let rUser)):
        return lUser.id == rUser.id
    default:
        return false
    }
}

extension ObservableConvertibleType where E == AddFriendsModel {
    func mapAndFilterSearchTap() -> Observable<User> {
        return self.asObservable().flatMap { (model) -> Observable<User> in
            switch model {
            case .searchResult(let user): return Observable.just(user)
            default: return Observable.empty()
            }
        }
    }

    func mapAndFilterUserTap() -> Observable<User> {
        return self.asObservable().flatMap { (model) -> Observable<User> in
            switch model {
            case .addedFriend(let user): return Observable.just(user)
            default: return Observable.empty()
            }
        }
    }
}
