//
//  FirstBasketViewController.swift
//  Basket
//
//  Created by Mario Radonic on 02/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FirstBasketViewController: BaseViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var emptyBasketImageView: TintableImageView!

    let disposeBag = DisposeBag()

    var originalPoint: CGPoint?
    let Threshold: CGFloat = 100

    fileprivate let createBasketSubject = PublishSubject<Bool>()
    var createBasketTapped: ControlEvent<Bool> {
        return ControlEvent(events: createBasketSubject.asObservable())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = UIFont.bsktBiggerMediumFont()
        titleLabel.textColor = UIColor.bsktWarmGreyColor()

        addImageViewGestureRecognizer()

        navigationItem.title = "Baskets".uppercased()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emptyBasketImageView.removeTint()
        if let originalPoint = originalPoint {
            UIView.animate(withDuration: 1, animations: {
                self.itemImageView.center = originalPoint
            })
        }
    }

    fileprivate func addImageViewGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FirstBasketViewController.handleItemImagePan(_:)))
        panGestureRecognizer.delegate = self
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(panGestureRecognizer)
    }

    func handleItemImagePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let xFromCenter = gestureRecognizer.translation(in: itemImageView).x
        let yFromCenter = gestureRecognizer.translation(in: itemImageView).y

        switch(gestureRecognizer.state) {
        case .began:
            originalPoint = itemImageView.center
        case .changed:
            if let point = originalPoint , yFromCenter > 0 {
                itemImageView.center = CGPoint(x: point.x, y: point.y + yFromCenter)
            }
            if yFromCenter > 150 {
                emptyBasketImageView.tintImage()
            } else {
                emptyBasketImageView.removeTint()
            }
        case .ended:
            panEnded(xFromCenter, yShift: yFromCenter).bindTo(createBasketSubject).addDisposableTo(disposeBag)
        default:
            return
        }
    }

    func panEnded(_ xShift: CGFloat, yShift: CGFloat) -> Observable<Bool> {
        if yShift > 150 {
            emptyBasketImageView.tintImage()
        } else {
            returnToInitialPosition()
            emptyBasketImageView.removeTint()
        }

        return Observable.create({ (observer) -> Disposable in
            if yShift > 150 {
                observer.onNext(true)
            }
            return Disposables.create()
        })
    }

    func returnToInitialPosition() {
        UIView.animate(withDuration: 0.5,
            animations: {
                self.itemImageView.center = self.originalPoint ?? CGPoint.zero
            }, completion: { completed in
        })
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
            let superview = itemImageView.superview
        else {
            return false
        }
        let translationPoint = panGestureRecognizer.translation(in: superview)
        return fabs(translationPoint.y) > fabs(translationPoint.x) && translationPoint.y > 0
    }

    deinit {
        print("first basket VC did deinit")
    }
}
