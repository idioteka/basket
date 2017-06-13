//
//  RxTwoWayBinding.swift
//  Base
//
//  Created by Mario Radonic on 5/18/16.
//  Copyright © 2016 Five Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <->

public func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted: {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}
