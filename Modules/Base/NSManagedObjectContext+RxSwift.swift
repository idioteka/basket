//
//  NSManagedObjectContext+RxSwift.swift
//  Basket
//
//  Created by Mario Radonic on 4/16/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import AERecord

extension NSManagedObjectContext {

    func rx_entities<T: NSManagedObject>() -> Observable<[T]> {
        return Observable.create { observer in
            let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()
            fetchRequest.sortDescriptors = []
            let frc: NSFetchedResultsController<T> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: nil, cacheName: nil)
            let observerAdapter = FetchResultControllerEntityObserver(observer: observer, frc: frc)
            return Disposables.create {
                observerAdapter.dispose()
            }
        }
    }

    func rx_entitiesForFetchedResultsController<T: NSManagedObject>
        (_ fetchedResultsController: NSFetchedResultsController<T>) -> Observable<[T]> {

            return Observable.create { observer in
                let observerAdapter = FetchResultControllerEntityObserver(observer: observer, frc: fetchedResultsController)
                return Disposables.create {
                    observerAdapter.dispose()
                }
            }
    }
}
