//
//  Delay.swift
//  Basket
//
//  Created by Mario Radonic on 4/16/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}

func measureTime<T>(_ f: () -> (T)) -> T {
    let startTime = CFAbsoluteTimeGetCurrent()
    let res = f()
    let endTime = CFAbsoluteTimeGetCurrent()
    print("Elapsed time is \((endTime - startTime)*1000) ms.")
    return res
}
