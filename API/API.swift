//
//  API.swift
//  Basket
//
//  Created by Mario Radonic on 2/12/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya

typealias JSONDictionary = [String: AnyObject]
typealias JSONArray = [JSONDictionary]

extension TargetType {
    var baseURL: URL {
        return URL(string: "http://bsktapp.com/api/v1/")!
    }
}

enum BasketAPI {
    case login(loginDetails: LoginDetails)
    case signup(userSignupDetails: UserSignupDetails)
    case facebookLogin(accessToken: String)
    case forgotPassword(email: String)
}

enum BasketAuthenticatedAPI {
    case refresh
    case baskets
    case basketDetails(Int)
    case invitationAction(action: BasketInvitationAction, basketId: Int, inviteId: Int)
    case itemAction(action: BasketItemAction, basketId: Int, itemId: Int)
    case createItem(basketId: Int, itemName: String)
    case searchUsers(String)
    case createBasket(firstStepData: CreateBasketFirstStepData, users: [Int])
    case addUserToBasket(userId: Int, basketId: Int)
    case splitBill(Int)
    case leaveBasket(basketId: Int, userId: Int)
    case activity(Int)
    case me
    case archiveBasket(Int)
    case updateUser(ProfileDetails)
}

extension BasketAPI: TargetType {
    var task: Task {
        return .request
    }

    var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }

    var addXAuth: Bool {
        return false
    }

    var path: String {
        switch self {
        case .login:
            return "auth/login"
        case .signup:
            return "auth/signup"
        case .facebookLogin:
            return "auth/facebook"
        case .forgotPassword:
            return "auth/forgot-password"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .signup, .facebookLogin, .forgotPassword:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .login(let credentials):
            return credentials.toJSONDictionary()
        case .signup(let details):
            return details.toJSONDictionary()
        case .facebookLogin(let token):
            return ["access_token": token]
        case .forgotPassword(let email):
            return ["email": email]
        }
    }

    var sampleData: Data {
        switch self {
        case .login, .signup:
            return stubbedResponse("Login")
        case .facebookLogin:
            fatalError("Not yet implemented")
        case .forgotPassword:
            fatalError("Not yet implemented")
        }
    }

}

extension BasketAuthenticatedAPI: TargetType {
    public var task: Task {
        return .request
    }

    var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }

    var path: String {
        switch self {
        case .baskets:
            return "baskets"
        case .basketDetails(let id):
            return "basket/\(id)"
        case .createBasket:
            return "baskets"
        case .invitationAction(_, let basketId, let inviteId):
            return "basket/\(basketId)/invites/\(inviteId)"
        case .itemAction(_, let basketId, let itemId):
            return "basket/\(basketId)/item/\(itemId)"
        case .createItem(let basketId, _):
            return "basket/\(basketId)/items"
        case .searchUsers:
            return "users/search"
        case .refresh:
            return "auth/refresh"
        case .addUserToBasket(let data):
            return "basket/\(data.basketId)/people"
        case .splitBill(let basketId):
            return "basket/\(basketId)/bill"
        case .leaveBasket(let BasketId, let userId):
            return "basket/\(BasketId)/people/\(userId)"
        case .activity(let basketId):
            return "basket/\(basketId)/activity"
        case .me:
            return "me"
        case .archiveBasket(let basketId):
            return "basket/\(basketId)/archive"
        case .updateUser:
            return "me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .baskets, .basketDetails, .refresh, .searchUsers, .splitBill, .activity, .me:
            return .get
        case .addUserToBasket, .createBasket, .createItem:
            return .post
        case .invitationAction, .itemAction, .archiveBasket, .updateUser:
            return .patch
        case .leaveBasket:
            return .delete
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .baskets, .basketDetails, .refresh, .splitBill, .leaveBasket, .activity, .me, .archiveBasket:
            return nil
        case .itemAction(action: let action, basketId: _, itemId: _):
            return action.parameters
        case .invitationAction(let action, basketId: _, inviteId: _):
            return [
                "is_accepted": action == BasketInvitationAction.accept,
                "is_blocked": action == BasketInvitationAction.rejectAndBlock
            ]
        case .createItem(_, let itemName):
            return ["name": itemName]
        case .searchUsers(let query):
            return ["query": query]
        case .createBasket(let firstStepData, let userIds):
            var data: JSONDictionary = [
                "name": firstStepData.name as AnyObject,
                "description": firstStepData.description as AnyObject,
                "is_locked": firstStepData.locked as AnyObject,
                "basketeers": userIds as AnyObject
            ]
            if let dueDate = firstStepData.dueDate { data["due_date"] = dueDate as AnyObject? }
            return data
        case .addUserToBasket(let data):
            return [
                "user_id": data.userId
            ]
        case .updateUser(let details):
            return details.toJSONDictionary()
        }
    }

    var sampleData: Data {
        switch self {
        case .baskets:
            return stubbedResponse("Baskets")
        case .basketDetails:
            return stubbedResponse("BasketDetails")
        case .createBasket, .createItem, .itemAction:
            fatalError("Not yet implemented")
        case .invitationAction:
            return stubbedResponse("Baskets") // TODO: not important really, only status code matters
        case .searchUsers:
            return stubbedResponse("Search")
        case .refresh:
            fatalError("Not yet implemented")
        case .addUserToBasket:
            fatalError("Not yet implemented")
        case .splitBill:
            fatalError("Not yet implemented")
        case .leaveBasket:
            fatalError("Not yet implemented")
        case .activity:
            fatalError("Not yet implemented")
        case .me:
            fatalError("Not yet implemented")
        case .archiveBasket:
            fatalError("Not yet implemented")
        case .updateUser:
            fatalError("Not yet implemented")
        }
    }

    var parameterEncoding: ParameterEncoding {
        switch self.method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}

func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    let url = URL(fileURLWithPath: path!)
    return try! Data(contentsOf: url)
}
