//
//  BasketDetailsViewController.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class BasketDetailsViewController: BaseViewController {

    let disposeBag = DisposeBag()

    let LocationViewContainerHeight: CGFloat = 282

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var isLockedIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notificationsInstructionsLabel: UILabel!
    @IBOutlet weak var leaveThisBasketButton: UIButton!
    @IBOutlet weak var muteSwitch: UISwitch!

    @IBOutlet weak var separatorView1: UIView!
    @IBOutlet weak var separatorView2: UIView!
    @IBOutlet weak var separatorView3: UIView!
    @IBOutlet weak var separatorView4: UIView!
    @IBOutlet weak var separatorView5: UIView!
    @IBOutlet weak var separatorView6: UIView!
    @IBOutlet weak var locationContainerView: UIView!

    @IBOutlet weak var locationContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelHorizontalConstraint: NSLayoutConstraint!
    var viewModel: BasketDetailsViewModel!

    fileprivate let directionsSubject = PublishSubject<((longitude: Double, latitude: Double)?, String?)>()
    var directionsTapped: ControlEvent<((longitude: Double, latitude: Double)?, String?)> {
        return ControlEvent(events: directionsSubject.asObservable())
    }

    fileprivate let leaveBasketSubject = PublishSubject<Void>()
    var leaveBasketTapped: ControlEvent<Void> {
        return ControlEvent(events: leaveBasketSubject.asObservable())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyDesign()

        viewModel.icon.asObservable().bindTo(iconLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.title.asObservable().bindTo(titleLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.dueDate.asObservable().bindTo(dueDateLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.description.asObservable().bindTo(descriptionLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.address.asObservable().bindTo(placeLabel.rx.text).addDisposableTo(disposeBag)

        viewModel.isMuted.asObservable().bindTo(muteSwitch.rx.value).addDisposableTo(disposeBag)

        viewModel.location.drive(onNext: { [weak self] (location) in
            self?.locationContainerView.isHidden = location == nil
            self?.locationContainerHeightConstraint.constant = (location == nil) ? 0 : (self?.LocationViewContainerHeight)!
        }).addDisposableTo(disposeBag)

        viewModel.isLocked.drive(onNext: { [weak self] (isLocked) in
            self?.isLockedIcon.isHidden = !isLocked
            self?.titleLabelHorizontalConstraint.constant = isLocked ? -9 : 0
        }).addDisposableTo(disposeBag)

        viewModel.location.drive(onNext: { [weak self] (location) in
            if let location = location {
                let initialLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let regionRadius: CLLocationDistance = 1000
                self?.mapView.region =  MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
                let annotation = MKPointAnnotation()
                let coordinateAnnotation = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                annotation.coordinate = coordinateAnnotation
                self?.mapView.addAnnotation(annotation)
            }
        }).addDisposableTo(disposeBag)

        let directions = self.directionsButton.rx.tap.map { [weak self] in (self?.viewModel.coordinates, self?.viewModel.addressString) }
        directions.bindTo(self.directionsSubject).addDisposableTo(disposeBag)

        self.leaveThisBasketButton.rx.tap.bindTo(self.leaveBasketSubject).addDisposableTo(disposeBag)

        viewModel.leaveBasketText.asObservable().bindTo(leaveThisBasketButton.titleLabel!.rx.text).addDisposableTo(disposeBag)
    }

    func applyDesign() {
        contentContainer.backgroundColor = UIColor.bsktWhiteColor()
        scrollView.backgroundColor = UIColor.bsktWhiteColor()
        titleLabel.font = UIFont.bsktBigBoldFont()
        titleLabel.textColor = UIColor.bsktGreyishBrownColor()
        dueDateLabel.font = UIFont.bsktMediumMediumFont()
        dueDateLabel.textColor = UIColor.bsktWarmGreyColor()
        descriptionLabel.font = UIFont.bsktMediumMediumFont()
        descriptionLabel.textColor = UIColor.bsktBrownishGreyColor()
        placeLabel.font = UIFont.bsktBigMediumFont()
        placeLabel.textColor = UIColor.bsktGreyishBrownColor()

        let stringBuilder = AttributedStringBuilder(globalColor: UIColor.bsktGreyishTwoColor(), globalFont: UIFont.bsktSmallerBoldFont())
        stringBuilder.appendString("LOCATION", letterSpacing: 0.8)
        locationLabel.attributedText = stringBuilder.buildString()
        directionsButton.setTitleColor(UIColor.bsktWindowsBlueColor(), for: UIControlState())
        directionsButton.titleLabel?.font = UIFont.bsktMediumMediumFont()
        notificationsLabel.font = UIFont.bsktBiggerRegularFont()
        notificationsLabel.textColor = UIColor.bsktGreyishBrownColor()
        notificationsInstructionsLabel.font = UIFont.bsktSmallishRegularFont()
        notificationsInstructionsLabel.textColor = UIColor.bsktWarmGreyColor()
        leaveThisBasketButton.setTitleColor(UIColor.bsktCoralColor(), for: UIControlState())
        leaveThisBasketButton.titleLabel?.font = UIFont.bsktBiggerMediumFont()

        separatorView1.backgroundColor = UIColor.bsktWhiteTwoColor()
        separatorView2.backgroundColor = UIColor.bsktWhiteTwoColor()
        separatorView3.backgroundColor = UIColor.bsktWhiteTwoColor()
        separatorView4.backgroundColor = UIColor.bsktWhiteTwoColor()
        separatorView5.backgroundColor = UIColor.bsktWhiteTwoColor()
        separatorView6.backgroundColor = UIColor.bsktWhiteTwoColor()
    }
}
