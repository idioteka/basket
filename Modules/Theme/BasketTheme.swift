//
//  BasketTheme.swift
//  Basket
//
//  Created by Mario Radonic on 4/2/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import UIKit

final class BasketTheme {

    // Singleton
    static let shared = BasketTheme()

    func setupAppereance() {
        setupNavigationBarAppearance()
        setupTabBarItemAppearance()
        setupTabBarAppearance()
    }

    fileprivate func setupNavigationBarAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.bsktSalmonColor()

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.bsktSmallerBoldFont()!
        ], for: UIControlState())
    }

    fileprivate func setupTabBarItemAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 10),
            NSForegroundColorAttributeName: UIColor.white
            ], for: .normal)

        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 10),
            NSForegroundColorAttributeName: UIColor.bsktSalmonColor()
            ], for: .selected)
    }

    fileprivate func setupTabBarAppearance() {
        UITabBar.appearance().barTintColor = UIColor.bsktDarkColor()
        UITabBar.appearance().isTranslucent = false
    }
}
