//
//  SettingsViewController.swift
//  Basket
//
//  Created by Mario Radonic on 5/1/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import TOCropViewController

class EditProfileViewController: BaseViewController {

    let disposeBag = DisposeBag()

    var viewModel: EditProfileViewModel!

    @IBOutlet weak var chooseAvatarButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    fileprivate var newAvatar: Driver<String> = Driver.empty()

    fileprivate let actionSubject = PublishSubject<(BasketItemAction, Int)>()
    var itemAction: ControlEvent<(BasketItemAction, Int)> {
        return ControlEvent(events: actionSubject)
    }


    var events: Driver<ProfileEvent> {
        return eventsSubject.asDriver(onErrorJustReturn: .error)
    }

    fileprivate var eventsSubject = PublishSubject<ProfileEvent>()

    var saveTapped: Driver<()> {
        return saveBarButtonItem.rx.tap.takeUntil(rx.deallocated).asDriver(onErrorJustReturn: ())
    }

    fileprivate let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: nil, action: nil)

    var outputs: ProfileViewOutputs {
        let b = firstNameTextField.rx.text.orEmpty.asDriver()
        return ProfileViewOutputs(
            firstName: b,
            lastName: lastNameTextField.rx.text.orEmpty.asDriver(),
            avatar: newAvatar.debug("avarat new"),
            saveTapped: saveTapped
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.saveEnabled.debug("save enabled")
            .drive(saveBarButtonItem.rx.isEnabled)
            .addDisposableTo(disposeBag)

        navigationItem.title = "Edit Profile".uppercased()
        navigationItem.rightBarButtonItem = saveBarButtonItem

        setupImageView()

        emailLabel.font = UIFont.bsktMediumMediumFont()
        firstNameLabel.font = UIFont.bsktMediumMediumFont()
        lastNameLabel.font = UIFont.bsktMediumMediumFont()

        emailLabel.textColor = UIColor.bsktSalmonColor()
        firstNameLabel.textColor = UIColor.bsktSalmonColor()
        lastNameLabel.textColor = UIColor.bsktSalmonColor()

        logoutButton.tintColor = UIColor.bsktPastelRedColor()

        viewModel.firstName.asObservable().bindTo(firstNameTextField.rx.text).addDisposableTo(disposeBag)
        viewModel.lastName.asObservable().bindTo(lastNameTextField.rx.text).addDisposableTo(disposeBag)
        viewModel.email.asObservable().debug().bindTo(emailTextField.rx.text).addDisposableTo(disposeBag)

        viewModel.saveResult.map { (result) -> String? in
            switch result {
            case .error(let error):
                return error
            case .success:
                return nil
            }
        }.filterNil()
            .asDriver()
            .drive(simpleAlertWithTitle("Error"))
            .addDisposableTo(disposeBag)

        logoutButton.rx.tap
            .map { ProfileEvent.logoutTapped }
            .bindNext(eventsSubject.onNext)
            .addDisposableTo(disposeBag)

        chooseAvatarButton.rx.tap.flatMap { [weak self] _ -> Observable<UIImagePickerControllerSourceType> in
            guard let view = self else {
                return Observable.empty()
            }
            return view.showImageUploadTypePicker()
        }.subscribe(onNext: { [weak self] sourceType in
            guard let view = self else {
                return
            }
            view.newAvatar = view.chooseImageWithSourceType(sourceType).flatMap { image -> Observable<UIImage> in
                return view.showCropViewController(image)
                }.map({ image -> String in
                    image.toBase64String() ?? ""
                }).asDriver(onErrorJustReturn: "")

            view.newAvatar.drive(onNext: { image in
                view.dismiss(animated: true, completion: nil)
            }).addDisposableTo(view.disposeBag)
        }).addDisposableTo(disposeBag)
    }

    func setupImageView() {
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        avatarImageView.layer.borderColor = UIColor.bsktWarmGreyColor().cgColor
        avatarImageView.layer.borderWidth = 1.0
    }

    func showCropViewController(_ image: UIImage) -> Observable<UIImage> {
        let cropViewController = TOCropViewController(image: image)
        self.avatarImageView.image = image
        self.present(cropViewController, animated: true, completion: nil)

        return cropViewController.rx_didCropToImage
    }

    func chooseImageWithSourceType(_ sourceType: UIImagePickerControllerSourceType) -> Observable<UIImage> {
        return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = sourceType
                picker.allowsEditing = false
            }.flatMap { (pickerController) -> Observable<(UIImage, UIViewController?)> in
                return pickerController.rx.didFinishPickingMediaWithInfo.map({ info -> UIImage in
                    return (info[UIImagePickerControllerOriginalImage] as! UIImage)
                }).map { ($0, pickerController) }
            }.take(1).flatMapLatest { (image, viewController) -> Observable<UIImage> in
                return viewController?.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:))).map { _ in image } ?? Observable.empty()
            }
    }

    func showImageUploadTypePicker() -> Observable<UIImagePickerControllerSourceType> {

        return Observable.create({ (observer) -> Disposable in
            let actionSheet = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                observer.onCompleted()
            })
            actionSheet.addAction(cancelAction)

            let rejectAction = UIAlertAction(title: "Take New Photo", style: .default, handler: { _ in
                observer.onNext(.camera)
                observer.onCompleted()
            })
            actionSheet.addAction(rejectAction)

            let rejectAndBlockAction = UIAlertAction(title: "Choose From Phone", style: .default, handler: { _ in
                observer.onNext(.photoLibrary)
                observer.onCompleted()
            })
            actionSheet.addAction(rejectAndBlockAction)

            self.present(actionSheet, animated: true, completion: nil)

            return Disposables.create()
        })

    }
}

