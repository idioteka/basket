//
//  FetchResultControllerEntityObserver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import CoreData

// swiftlint:disable
class FetchResultControllerEntityObserver<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, Disposable {
    typealias Observer = AnyObserver<[T]>

    let observer: Observer
    let frc: NSFetchedResultsController<T>

    init(observer: Observer, frc: NSFetchedResultsController<T>) {
        self.observer = observer
        self.frc = frc

        super.init()

        self.frc.delegate = self

        do {
            try self.frc.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }

        sendNextElement()
    }

    func sendNextElement() {
        let entities = self.frc.fetchedObjects
        observer.onNext(entities ?? [])
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

    func dispose() {
        self.frc.delegate = nil
    }
}
// swiftlint:enable
