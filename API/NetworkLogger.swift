//
//  NetworkLogger.swift
//  Basket
//
//  Created by Mario Radonic on 4/2/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import Moya
import Result

/// Logs network activity (outgoing requests and incoming responses).
class NetworkLogger: PluginType {


    func willSendRequest(_ request: RequestType, target: TargetType) {
        print("Sending request: \(request.request?.url?.absoluteString ?? String())")
        debugPrint(request)
    }

    func didReceiveResponse(_ result: Result<Moya.Response, Moya.Error>, target: TargetType) {
        switch result {
        case .success(let response):
            if 200..<400 ~= (response.statusCode)  {
                // If the status code is OK, and if it's not in our whitelist, then don't worry about logging its response body.
                print("Received response(\(response.statusCode )) from \(response.response?.url?.absoluteString ?? String()).")
            }
        case .failure(let error):
            // Otherwise, log everything.
            print("Received networking error: \(error)")
        }
        print(result.debugDescription)
    }
}
