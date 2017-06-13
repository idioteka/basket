//
//  UIPickerView+Rx.swift
//  Basket
//
//  Created by Mario Radonic on 5/21/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol PickerModelType {
    var title: String { get }
}

class UIPickerDelegateProxy: DelegateProxy, UIPickerViewDelegate, DelegateProxyType, UIPickerViewDataSource {

    fileprivate var models = [PickerModelType]()

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func modelAtRow(_ row: Int) -> PickerModelType {
        return models[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return models.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modelAtRow(row).title
    }

    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        guard let object = object as? UIPickerView else {
            fatalError()
        }
        return object.delegate
    }

    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let delegate = delegate else {
            return
        }

        guard let object = object as? UIPickerView else {
            fatalError()
        }

        object.delegate = (delegate as! UIPickerViewDelegate)
    }
}

extension UIPickerView {
    public var rx_delegate: DelegateProxy {
        return UIPickerDelegateProxy.proxyForObject(self)
    }

    var rx_didSelectRow: Observable<Int> {
        return rx_delegate.methodInvoked(#selector(UIPickerViewDelegate.pickerView(_:didSelectRow:inComponent:))).map { (a) -> Int in
            return a[1] as! Int
        }
    }

    func rx_didSelectModel<T: PickerModelType>() -> Observable<T> {
        return rx_didSelectRow.flatMap({ [weak self] (row) -> Observable<T> in
            guard let picker = self else { return Observable.empty() }
            let dataSource = picker.rx_dataSource
            guard let model = dataSource.modelAtRow(row) as? T else { return Observable.empty() }
            return Observable.just(model)
        })
    }

    fileprivate var rx_dataSource: UIPickerDelegateProxy {
        return rx_delegate as! UIPickerDelegateProxy
    }

    func rx_models<T: PickerModelType>() -> AnyObserver<[T]> {
        self.dataSource = rx_dataSource

        return UIBindingObserver(UIElement: self) { (picker, titles) in
            picker.rx_dataSource.models = titles.map { $0 as PickerModelType }
            picker.reloadComponent(0)
        }.asObserver()
    }
}
