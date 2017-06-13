//
//  CreateBasketViewModel.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CurrenciesParser {
    static func getCurrencies() -> [Currency] {
        let jsonFileName = "Currency_List"
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: jsonFileName, ofType: "json") else {
            fatalError("No json file named \(jsonFileName)")
        }
        let fileURL = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: fileURL) else {
            fatalError("Couldn't read file named \(jsonFileName)")
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            fatalError("Couldn't create json")
        }
        guard let jsonArray = json as? JSONArray else {
            fatalError("File is not json array")
        }
        return jsonArray.flatMap { try? Currency(json: $0) }
    }
}

class CreateBasketViewModel {
    let doneEnabled: Driver<Bool>
    let data: Driver<CreateBasketFirstStepData>
    let availableCurrencies: Driver<[Currency]>
    let dueDateText: Driver<String>
    let currencyText: Driver<String>

    init(events: Driver<CreateBasketEvent>, startWithData: CreateBasketFirstStepData = CreateBasketFirstStepData.empty) {
        self.data = events.scan(startWithData) { (data, event) in
            return data.dataUpdatedWith(event)
        }.startWith(startWithData)

        doneEnabled = data.map { $0.isValid }

        self.availableCurrencies = Observable<Void>.just()
            .subscribeOn(AppDependencies.shared.backgroundWorkScheduler)
            .map { CurrenciesParser.getCurrencies() }
            .map { $0.sorted { l, r in
                if l.popular && !r.popular {
                    return true
                } else if r.popular && !l.popular {
                    return false
                }
                return l.code < r.code
                }
            }
            .asDriver(onErrorJustReturn: [])

        self.dueDateText = data.map { $0.dueDate }.map { $0?.dateString }.map { $0 ?? "Not set" }
        self.currencyText = data
            .map { $0.currency }
            .map { $0.code }
    }
}

struct CreateBasketFirstStepData {
    var name: String
    var description: String
    var dueDate: Date?
    var locked: Bool
    var location: LocationRaw?
    var currency: Currency

    static var empty: CreateBasketFirstStepData {
        return CreateBasketFirstStepData(
            name: "", description: "",
            dueDate: nil, locked: false, location: nil,
            currency: Currency.defaultCurrency)
    }

    func dataUpdatedWith(_ event: CreateBasketEvent) -> CreateBasketFirstStepData {
        var copy = self
        switch event {
        case .nameChanged(let name):
            copy.name = name
        case .descriptionChanged(let description):
            copy.description = description
        case .dueDateChanged(let date):
            copy.dueDate = date
        case .lockedChanged(let locked):
            copy.locked = locked
        case .cancelTapped, .nextTapped, .error:
            break
        case .locationChanged(let location):
            copy.location = location
        case .currencyChanged(let currency):
            copy.currency = currency
        case .resetDateTapped:
            copy.dueDate = nil
        }
        return copy
    }

    var isValid: Bool {
        return !name.isEmpty && !description.isEmpty
    }
}
