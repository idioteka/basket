//
//  Networking.swift
//  Basket
//
//  Created by Mario Radonic on 2/12/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

protocol NetworkingType {
    associatedtype T: TargetType
    var provider: RxMoyaProvider<T> { get }
}


//private let stubBehavior = StubBehavior.Delayed(seconds: 2)
private let stubBehavior = StubBehavior.never

struct Networking: NetworkingType {
    let provider = RxMoyaProvider<BasketAPI>(
        endpointClosure: { target in
            return Networking.DefaultEndpointMapping(target)
        },
        stubClosure: { _ in stubBehavior },
        plugins: Networking.plugins
    )
}

struct AuthorizedNetworking: NetworkingType {

    let provider: RxMoyaProvider<BasketAuthenticatedAPI>

    init(tokens: APITokens) {

        self.provider = AuthorizedProvider<BasketAuthenticatedAPI>(
            tokens: tokens,
            stubClosure: { _ in stubBehavior },
            plugins: Networking.plugins)
    }
}


extension Networking {
    static var plugins: [PluginType] {
        return [NetworkLogger()]
    }

    static func DefaultEndpointMapping<Target: TargetType>(_ target: Target) -> Endpoint<Target> {
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        return Endpoint(
            URL: url,
            sampleResponseClosure: {.networkResponse(200, target.sampleData)},
            method: target.method,
            parameters: target.parameters,
            parameterEncoding: Moya.JSONEncoding.default)
    }
}

class AuthorizedProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    fileprivate(set) var tokens: APITokens
    fileprivate(set) var useRefreshToken = false

    init(tokens: APITokens, stubClosure: @escaping MoyaProvider<Target>.StubClosure, plugins: [PluginType]) {
        self.tokens = tokens

        super.init(endpointClosure: Networking.DefaultEndpointMapping, stubClosure: stubClosure, plugins: plugins)
    }

    override func request(_ token: Target) -> Observable<Moya.Response> {
        let originalRequest = super.request(token)

        guard let originalToken = token as? BasketAuthenticatedAPI else {
            return originalRequest
        }

        let isRefreshToken: Bool
        switch originalToken {
        case .refresh: isRefreshToken = true
        default: isRefreshToken = false
        }

        if isRefreshToken {
            return originalRequest
        }

        return originalRequest.flatMap { (originalResponse) -> Observable<Moya.Response> in
            do {
                return Observable.just(try originalResponse.filterSuccessfulStatusCodes())
            } catch {
                guard originalResponse.statusCode == 401 else {
                    return Observable.just(originalResponse)
                }
                guard let refreshToken = BasketAuthenticatedAPI.refresh as? Target else {
                    return Observable.just(originalResponse)
                }

                return self.request(refreshToken).flatMap { (refreshResponse) -> Observable<Moya.Response> in
                    do {
                        _ = try refreshResponse.filterSuccessfulStatusCodes()
                        let json = try refreshResponse.mapJSONDictionry()
                        let newTokens = try APITokens(json: json, userId: self.tokens.userId)
                        try newTokens.saveToKeychain()
                        self.tokens = newTokens

                        return originalRequest
                    } catch {
                        return Observable.just(originalResponse)
                    }
                }
            }
        }
    }

    override func endpoint(_ token: Target) -> Endpoint<Target> {
        var sup = super.endpoint(token)
        var authToken: String = ""

        if let token = token as? BasketAuthenticatedAPI {
            sup = sup.adding(newParameterEncoding: token.parameterEncoding)
        }

        if let token = token as? BasketAuthenticatedAPI {
            switch token {
            case .refresh:
                authToken = self.tokens.refreshToken
            default:
                authToken = self.tokens.accessToken
            }
        }

        return sup.adding(newHttpHeaderFields: ["Authorization": "Bearer \(authToken)"])
    }
}
