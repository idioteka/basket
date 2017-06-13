//
//  PickerToolbar.swift
//  Basket
//
//  Created by Mario Radonic on 5/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import RxCocoa

enum PickerToolbarEvent {
    case doneTapped
    case cancelTapped
    case resetTapped
}

class PickerToolbar: UIView {

    fileprivate let doneButton = UIButton()
    fileprivate let cancelButton = UIButton()
    fileprivate let resetButton = UIButton()

    var showReset: Bool {
        get { return !resetButton.isHidden }
        set { resetButton.isHidden = !newValue }
    }

    fileprivate(set) var events: Observable<PickerToolbarEvent>!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    fileprivate func setup() {
        self.events = Observable.of(
            doneButton.rx.tap.map { PickerToolbarEvent.doneTapped },
            cancelButton.rx.tap.map { PickerToolbarEvent.cancelTapped },
            resetButton.rx.tap.map { PickerToolbarEvent.resetTapped }
        ).merge()

        addSubview(doneButton)
        addSubview(cancelButton)
        addSubview(resetButton)

        cancelButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .trailing)
        doneButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .leading)
        resetButton.autoPinEdge(toSuperviewEdge: .top)
        resetButton.autoPinEdge(toSuperviewEdge: .bottom)
        resetButton.autoPinEdge(.trailing, to: .leading, of: doneButton)

        [doneButton, cancelButton, resetButton].forEach {
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            $0.setTitleColor(UIColor.darkText, for: UIControlState())
            $0.titleLabel?.font = UIFont.bsktMediumMediumFont()
        }
        doneButton.setTitle("Done", for: UIControlState())
        cancelButton.setTitle("Cancel", for: UIControlState())
        resetButton.setTitle("Reset", for: UIControlState())
        backgroundColor = UIColor.bsktWhiteTwoColor()

    }

    func observe(_ event: PickerToolbarEvent) -> Observable<Void> {
        return events.filter { $0 == event }.mapVoid()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 44)
    }
}
