//
//  MainTabBarController.swift
//  Basket
//
//  Created by Mario Radonic on 12/03/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import RxSwift

class MainTabBarController: UITabBarController {

    var viewModel :MainTabBarViewModel!
    
    let disposeBag = DisposeBag()
    fileprivate var navigationTitleContent = NavigationTitleContent(title: "", subtitle: nil, imageName: nil)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(viewModel: MainTabBarViewModel, navigationTitleContent: NavigationTitleContent) {
        self.viewModel = viewModel
        self.navigationTitleContent = navigationTitleContent
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(viewModel != nil)
        
        viewModel.basket.filterSuccess().map { (basket) -> NavigationTitleContent in
            let imageName:String? = basket.isLocked ? "navigationBarLock" : nil
            return NavigationTitleContent(title: basket.name ?? "", subtitle: basket.basketSummary, imageName: imageName)
            }.startWith(navigationTitleContent).distinctUntilChanged().drive(onNext: { [weak self] in
            self?.navigationItem.titleView = NavigationTitleView(title: $0.title, subtitle: $0.subtitle, imageName: $0.imageName)
        }).addDisposableTo(disposeBag)
    }

    deinit {
        print("Main tab bar did deinit")
    }
}
