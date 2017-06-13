//
//  AppDependencies.swift
//  Basket
//
//  Created by Mario Radonic on 4/2/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift

protocol LaunchRouterDependencies {
    
}
struct AppDependencies {
    static let shared = AppDependencies()

    let authenticationService = AuthenticationService(networking: Networking())
    let backgroundWorkScheduler: ImmediateSchedulerType

    init() {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }
}
