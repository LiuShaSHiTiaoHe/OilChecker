//
//  AppDelegate.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/15.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializeApp()
        return true
    }

    func initializeApp() {
        window?.makeKeyAndVisible()
        let ctrl = ViewController.init()
        let navCtrl = UINavigationController.init(rootViewController: ctrl)
        UIApplication.shared.keyWindow?.rootViewController = navCtrl
    }


}

