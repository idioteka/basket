//
//  User.swift
//  Basket
//
//  Created by Mario Radonic on 4/9/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import CoreData
import AERecord

class User: NSManagedObject {

    class func createWith(jsonDictionary: JSONDictionary) throws -> User {
        guard let id = jsonDictionary["id"] as? Int else {
                print("Error creating user from json ")
                print(jsonDictionary)
                throw APIError.errorParsingJSON
        }

        let user = User.firstOrCreate(with: ["id": id])

        user.name = fullNameFrom(jsonDictionary)
        user.firstName = jsonDictionary.string(APIConstant.Key.firstName) ?? ""
        user.lastName = jsonDictionary.string(APIConstant.Key.lastName) ?? ""
        user.email = jsonDictionary.string(APIConstant.Key.email) ?? ""
        user.avatar = jsonDictionary.string(APIConstant.Key.avatar) ?? ""

        return user
    }

    class func getWithId(_ id: Int) -> User? {
        return User.first(with: "id", value: id)
    }

    static func fetchResultsControllerFor(id: Int) -> NSFetchedResultsController<User> {
        let fetchRequest: NSFetchRequest<User> = User.createFetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: AERecord.Context.default,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        return frc
    }
}

private func fullNameFromConcatenatedFirstAndLastNameFrom(_ json: JSONDictionary) -> String? {
    if let firstName = json[APIConstant.Key.firstName] as? String, let lastName = json[APIConstant.Key.lastName] as? String {
        return firstName + " " + lastName
    }
    return nil
}

private func fullNameFrom(_ json: JSONDictionary) -> String? {
    return (json[APIConstant.Key.name] as? String) ?? fullNameFromConcatenatedFirstAndLastNameFrom(json)
}
