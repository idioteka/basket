//
//  FriendsViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 4/24/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FriendsViewModel {
    var emptySearch: Driver<Void> { get }
    var searchUserResults: Driver<[User]>  { get }
    var users: Driver<[User]> { get }
}
