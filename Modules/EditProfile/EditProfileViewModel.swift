//
//  EditProfileViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 5/1/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AERecord

struct ProfileDetails {
    let firstName: String
    let lastName: String
    let avatar: String

    static var empty:ProfileDetails {
        return ProfileDetails(firstName: "", lastName: "", avatar: "")
    }

    var areValid: Bool {
//        return !firstName.isEmpty || !lastName.isEmpty || !avatar.isEmpty
        return true
    }

    func toJSONDictionary() -> JSONDictionary {
        var parameters = JSONDictionary()
        if !firstName.isEmpty {
            parameters["first_name"] = firstName as AnyObject?
        }
        if !lastName.isEmpty {
            parameters["last_name"] = lastName as AnyObject?
        }
        if !avatar.isEmpty {
            parameters["avatar"] = avatar as AnyObject?
        }

        return parameters
    }
}

typealias ProfileViewOutputs = ProfileViewModelInputs

struct ProfileViewModelInputs {
    let firstName: Driver<String>
    let lastName: Driver<String>
    let avatar: Driver<String>
    let saveTapped: Driver<Void>
}

enum UpdateUserResult {
    case success(user: User)
    case error(error: String)
}

class EditProfileViewModel {
    let userId: Int

    let disposeBag = DisposeBag()

    let firstName: Driver<String>
    let lastName: Driver<String>
    let email: Driver<String>

    let saveEnabled: Driver<Bool>
    let saveResult: Driver<UpdateUserResult>

    var startDetails = ProfileDetails.empty

    init(events: Driver<ProfileEvent>, inputs: ProfileViewModelInputs, authService: AuthenticationService, userService: UserService, userId: Int) {
        self.userId = userId

        let frc = User.fetchResultsControllerFor(id: userId)

        let usersInCD: Observable<[User]> = AERecord.Context.default.rx_entitiesForFetchedResultsController(frc).shareReplayLatestWhileConnected()

        let userInCD = usersInCD
            .mapAndFilterNil { $0.first }
            .shareReplayLatestWhileConnected()
            .map { CachedItemsResult.success(item: $0) }

        let refreshedUser = userService.refreshCurrentUser()
        let refreshedUserWithStart = refreshedUser.startWith(CachedItemsResult.loading)

        let mergedUser = Observable.of(userInCD, refreshedUserWithStart).merge()
            .shareReplayLatestWhileConnected().asDriver(onErrorJustReturn: .error)

        self.firstName = mergedUser.map {
            result -> String in
            switch result {
            case .error:
                return ""
            case .loading:
                return ""
            case .success(let user):
                return user.firstName ?? ""
            }
        }

        self.lastName = mergedUser.map {
            result -> String in
            switch result {
            case .error:
                return ""
            case .loading:
                return ""
            case .success(let user):
                return user.lastName ?? ""
            }
        }

        self.email = mergedUser.map {
            result -> String in
            switch result {
            case .error:
                return ""
            case .loading:
                return ""
            case .success(let user):
                return user.email ?? ""
            }
        }

        events
            .filter { $0 == ProfileEvent.logoutTapped }
            .drive(onNext: { (_) in
                authService.logout()
            }).addDisposableTo(disposeBag)

        if
            let userObject = User.first(with: NSPredicate(format: "id = %d", userId)),
            let firstName = userObject.firstName,
            let lastName = userObject.lastName {
                startDetails = ProfileDetails(firstName: firstName, lastName: lastName, avatar: "")
        }

        let userDetails = Observable.combineLatest(inputs.firstName.asObservable(), inputs.lastName.asObservable(), inputs.avatar.asObservable()) { firstName, lastName, avatar in
            return ProfileDetails(firstName: firstName, lastName: lastName, avatar: avatar)
            }
            .startWith(startDetails)
            .asDriver(onErrorJustReturn: ProfileDetails.empty).debug("user detals")

        saveEnabled = userDetails.map {
            return $0.areValid
        }.debug("user details changed")

        saveResult = inputs.saveTapped.withLatestFrom(userDetails).asObservable()
            .flatMapLatest { userService.updateCurrentUser(details: $0) }
            .asDriver(onErrorJustReturn: UpdateUserResult.error(error: "Error updating user"))

    }
}
