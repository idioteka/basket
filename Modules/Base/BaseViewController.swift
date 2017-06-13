//
//  BaseViewController.swift
//  Basket
//
//  Created by Mario Radonic on 2/12/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Keyboardy

class BaseViewController: UIViewController {

    var router: BaseRouter!

    fileprivate let _rxViewDidLoad = ReplaySubject<()>.create(bufferSize: 1)
    fileprivate let _rxViewWillAppear = ReplaySubject<()>.create(bufferSize: 1)
    fileprivate let _rxViewWillDisappear = ReplaySubject<()>.create(bufferSize: 1)

    var rxViewDidLoad: Observable<()> {
        return _rxViewDidLoad.asObservable()
    }

    var rxViewWillAppear: Observable<()> {
        return _rxViewWillAppear.asObservable()
    }

    var rxViewWillDisappear: Observable<()> {
        return _rxViewWillDisappear.asObservable()
    }

    override func viewDidLoad() {
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.bsktMediumBoldFont()!,
            NSForegroundColorAttributeName: UIColor.white
        ]

        let backBtn = UIImage(named: "icBackForTransparentBG")?.withRenderingMode(.alwaysTemplate)


        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = backBtn

        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backBtn

        _rxViewDidLoad.onNext(())
        _rxViewDidLoad.onCompleted()
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications(self)
        _rxViewWillAppear.onNext(())

        if preferrsNavigationBarTransparent() {
            setNavigationBarTransparent()
        } else {
            setNavigationBarNotTransparent()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromKeyboardNotifications()
        _rxViewWillDisappear.onNext(())
    }

    func setNavigationBarTransparent() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.clear
    }

    func setNavigationBarNotTransparent() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.bsktSalmonColor()
        navigationController?.navigationBar.barTintColor = UIColor.bsktDarkColor()
    }

    func onKeyboardHeightChange(_ height: CGFloat) {
    }

    func preferrsNavigationBarTransparent() -> Bool {
        return false
    }

    func safeButtonTap(_ buttonBlock: @escaping () -> UIButton?) -> Driver<Void> {
        let a = rxViewDidLoad.flatMap { () -> Observable<()> in
            guard let button = buttonBlock() else { return Observable.never() }
            return button.rx.tap.asObservable()
        }
        return a.asDriver(onErrorJustReturn: ())
    }

    func safeRxText(_ textfieldBlock: @escaping () -> UITextField?) -> Driver<String> {
        let a = rxViewDidLoad.flatMap { () -> Observable<String> in
            guard let textField = textfieldBlock() else { return Observable.never() }
            return textField.rx.text.orEmpty.asObservable()
        }
        return a.asDriver(onErrorJustReturn: "")
    }

    func simpleAlertWithTitle(_ title: String) -> AnyObserver<String> {
        return UIBindingObserver(UIElement: self, binding: { (vc, message) in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            vc.present(alert, animated: true, completion: nil)
        }).asObserver()
    }
}

extension BaseViewController: KeyboardStateDelegate {
    func keyboardWillTransition(_ state: KeyboardState) {
    }

    func keyboardTransitionAnimation(_ state: KeyboardState) {
        switch state {
        case .activeWithHeight(let height):
            onKeyboardHeightChange(height)
        case .hidden:
            onKeyboardHeightChange(0)
        }
    }

    func keyboardDidTransition(_ state: KeyboardState) {
    }
}
