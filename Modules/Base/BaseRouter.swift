//
//  BaseRouter.swift
//  Base
//
//  Created by Mario Radonic on 4/14/16.
//  Copyright © 2016 Five Agency. All rights reserved.
//

import Foundation
import RxSwift

class BaseRouter {
  fileprivate let deinitSubject = ReplaySubject<Void>.create(bufferSize: 1)

  var rxDeinit: Observable<Void> {
    return deinitSubject.asObservable()
  }

  /// Adds a reference of self to view controller, so it gets retained while view controller is alive
  ///
  /// - parameters:
  ///   - viewController: A view controller to add this router to
  func addViewController(_ viewController: BaseViewController) {
    viewController.router = self
  }

  deinit {
    deinitSubject.onNext(())
    deinitSubject.onCompleted()
  }
}
