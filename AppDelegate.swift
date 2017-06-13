//
//  AppDelegate.swift
//  Basket
//
//  Created by Mario Radonic on 2/11/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit
import AERecord
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        try! AERecord.loadCoreDataStack()

        BasketTheme.shared.setupAppereance()
        setupWindow()
        startApplication()

        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func setupWindow() {
        window = createWindow()
        window?.makeKeyAndVisible()
    }

    func createWindow() -> UIWindow {
        let bounds = UIScreen.main.bounds
        return UIWindow(frame: bounds)
    }

    func startApplication() {
        guard let window = window else {
            fatalError("Cannot start application if window is nil")
        }

        let launchRouter = LaunchRouter(window: window, authService: AppDependencies.shared.authenticationService)
        launchRouter.startApplication()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AERecord.save()
    }
}
