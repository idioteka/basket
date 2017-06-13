//
//  StaticTableViewController.swift
//  Basket
//
//  Created by Mario Radonic on 2/16/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift

open class StaticTableView: UIView {

    var contentView = UIScrollView()

    var rxViews = PublishSubject<[UIView]>()

    fileprivate let disposeBag = DisposeBag()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    fileprivate func setup() {
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()

        rxViews.subscribe(onNext: { [weak self] views in
            self?.removeAllSubviews()
            self?.addViews(views)
        }).addDisposableTo(disposeBag)
    }

    fileprivate func addViews(_ views: [UIView]) {
        guard views.count != 0 else {
            return
        }

        for (subViewIndex, subView) in views.enumerated() {
            let previousView: UIView? = subViewIndex > 0 ? views[subViewIndex - 1] : nil

            insert(subView, previousView: previousView)
            subView.autoPinEdge(.leading, to: .leading, of: self)
            subView.autoPinEdge(.trailing, to: .trailing, of: self)
        }

        if let lastView = views.last {
            lastView.autoPinEdge(toSuperviewEdge: .bottom)
        }
    }

    fileprivate func insert(_ subview: UIView, previousView: UIView?) {
        contentView.addSubview(subview)

        if let previousView = previousView {
            previousView.autoPinEdge(.bottom, to: .top, of: subview)
        } else {
            subview.autoPinEdge(toSuperviewEdge: .top)
        }
    }

    func removeAllSubviews() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}
