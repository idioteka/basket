//
//  CreateBasketViewController.swift
//  Basket
//
//  Created by Mario Radonic on 4/23/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateBasketViewController: BaseViewController {

    var viewModel: CreateBasketViewModel!
    let disposeBag = DisposeBag()

    // MARK: IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var lockedSwitch: UISwitch!

    @IBOutlet weak var nameFocusButton: UIButton!
    @IBOutlet weak var descriptionFocusButton: UIButton!
    @IBOutlet weak var changeCurrencyButton: UIButton!
    @IBOutlet weak var dueDateTextField: NoCursorTextField!

    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var locationValueLabel: UILabel!

    @IBOutlet weak var focusDueDateButton: UIButton!

    var tapGestureRecognizer: UITapGestureRecognizer!
    let currenyPickerView = UIPickerView()
    let dueDatePicker = UIDatePicker()
    let dueDateToolbar = PickerToolbar(forAutoLayout: ())

    let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: nil, action: nil)
    let nextButton = UIBarButtonItem(title: "NEXT", style: .plain, target: nil, action: nil)

    var currencies = [Currency]()

    override func viewDidLoad() {
        assert(viewModel != nil)
        super.viewDidLoad()
        setupNavigationItems()
        setupEndEditingGestureRecognizer()
        setupDueDatePicker()
        setupFocusButtons()
        setupCurrencyField()
        setupLocationValueLabel()

        bindViewModel()
    }

    func setupLocationValueLabel() {
        locationValueLabel.font = UIFont.bsktBiggerRegularFont()
        locationValueLabel.textColor = UIColor.bsktWarmGreyTwoColor()
    }
    func setupCurrencyField() {
        currencyTextField.inputView = currenyPickerView

        currenyPickerView.backgroundColor = UIColor.white

        changeCurrencyButton.rx.tap.subscribe(onNext: {
            self.currencyTextField.becomeFirstResponder()
        }).addDisposableTo(disposeBag)

    }

    func setupFocusButtons() {
        focusDueDateButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dueDateTextField.becomeFirstResponder()
        }).addDisposableTo(disposeBag)

        nameFocusButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.nameTextField.becomeFirstResponder()
        }).addDisposableTo(disposeBag)

        descriptionFocusButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.descriptionTextView.becomeFirstResponder()
        }).addDisposableTo(disposeBag)
    }

    func setupDueDatePicker() {
        dueDateTextField.inputView = dueDatePicker
        dueDatePicker.minimumDate = Date()

        dueDateTextField.inputAccessoryView = dueDateToolbar
        dueDateToolbar.frame = CGRect(x: 0, y: 0, width: 320, height: 44)

        dueDatePicker.datePickerMode = UIDatePickerMode.date

        dueDateToolbar.events.mapVoid()
            .subscribe(onNext: { [weak self] in
                self?.dueDateTextField.resignFirstResponder()
            }).addDisposableTo(disposeBag)
        dueDatePicker.backgroundColor = UIColor.white
    }

    func setupEndEditingGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateBasketViewController.cancelEditing))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupNavigationItems() {
        navigationItem.title = "CREATE A BASKET"
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.bsktMediumMediumFont()!,
            NSForegroundColorAttributeName: UIColor.white
        ]
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = nextButton
    }
    func bindViewModel() {
        viewModel.doneEnabled
            .drive(nextButton.rx.isEnabled)
            .addDisposableTo(disposeBag)

        viewModel.currencyText
            .drive(currencyTextField.rx.text)
            .addDisposableTo(disposeBag)

        viewModel.availableCurrencies
            .drive(currenyPickerView.rx_models())
            .addDisposableTo(disposeBag)

        viewModel.dueDateText
            .drive(dueDateTextField.rx.text)
            .addDisposableTo(disposeBag)
    }

    func cancelEditing() {
        view.endEditing(true)
    }

    override func onKeyboardHeightChange(_ height: CGFloat) {
        var insets = scrollView.contentInset
        insets.bottom = height
        scrollView.contentInset = insets
    }

    deinit {
        print("Create basket did deinit")
    }
}

extension Currency: PickerModelType {
    var title: String {
        return self.code
    }
}

// MARK: Outputs
extension CreateBasketViewController {
    var event: Driver<CreateBasketEvent> {
        return self.rxViewDidLoad.asDriver(onErrorJustReturn: ()).flatMapLatest { [unowned self] () -> Driver<CreateBasketEvent> in
            let cancelTapped = self.cancelButton.rx.tap.map { CreateBasketEvent.cancelTapped }
            let doneTapped = self.nextButton.rx.tap.map { CreateBasketEvent.nextTapped }
            let nameChanged = self.nameTextField.rx.text.map { CreateBasketEvent.nameChanged($0!) }
            let descriptionChagned = self.descriptionTextView.rx.text.map { CreateBasketEvent.descriptionChanged($0!) }
            let lockedChagned = self.lockedSwitch.rx.value.map { CreateBasketEvent.lockedChanged($0) }
            let currencyChanged: Observable<Currency> = self.currenyPickerView.rx_didSelectModel()
            let currencyChangedEvent = currencyChanged.map { CreateBasketEvent.currencyChanged($0) }
            let dueDateChanged = self.dueDatePicker.rx.date.skip(1).map { CreateBasketEvent.dueDateChanged($0) }
            let resetDate = self.dueDateToolbar.observe(PickerToolbarEvent.resetTapped).map { CreateBasketEvent.resetDateTapped }

            let merged = Observable.of(
                cancelTapped, doneTapped, nameChanged,
                descriptionChagned, lockedChagned, currencyChangedEvent,
                dueDateChanged, resetDate)
                .merge()
            return merged.asDriver(onErrorJustReturn: .error)
        }
    }
}
