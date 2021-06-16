//
//  AppDelegate.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/15.
//

import UIKit
import SnapKit
import ESTabBarController_swift
import IQKeyboardManagerSwift
import SwiftDate
import SwifterSwift
import CoreBluetooth
import SwiftyUserDefaults
import SVProgressHUD
import Logging

let logger = Logger(label: "com.OilChecker.main")
//let logger = TLogFactory.createTLog(forModuleName: "com.OilChecker.main")!
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initializeApp()
        
//        AlicloudTlogProvider.init().autoInit(withAppVersion: "1.0.0", channel: "debug", nick: "oilchecker")
//        AlicloudHAProvider.start()
//        TRDManagerService.update(.info)

//        let loggerr = TLogFactory.createTLog(forModuleName: "com.OilChecker.UIApplicationDelegate")!
//        loggerr.info("UIApplicationDelegate")
//        let uuidString = "FFE1"
//        if uuidString != "FFE1" && uuidString != "FFE2" {
//            logger.info("\(NSHomeDirectory())")
//        }
//        var binary = Binary.init(hexString: "020AF600000008400")!
//        let count = binary.count
//        let qw = try? binary.readBytes(1)//stx
//        let ass = try? binary.readBytes(1)//dataLength
//        let df = try? binary.readBytes(1)//length comp
//        let dataDeviceID = try? binary.readBytes(2)//deviceID
//        let property = try? binary.readBytes(1)
//        let cmd = try? binary.readBytes(1)
//        let response = try? binary.readBytes(1)
        
        let remoteData = 0x0700
        let singleData:[UInt8] = [0x07,0x00]
        let number = OCByteManager.shared.integer(from: singleData.hexa)
        let local = CFSwapInt16BigToHost(UInt16(number))
        
        logger.info("\(NSHomeDirectory())")
        return true
    }
  
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func initializeApp() {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window!.rootViewController = initializeRootViewController()
        self.window?.overrideUserInterfaceStyle = .light;
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        self.window?.makeKeyAndVisible()
    }
    

    func addFakeData() {
        
        RealmHelper.clearTableClass(objectClass: BaseFuelDataModel())
        var dataSource: [BaseFuelDataModel] = []
        for index in 1...1000 {
            let data = Double(arc4random_uniform(100))+50
            let baseFuelModel = BaseFuelDataModel.init()
            baseFuelModel.deviceID = "2345"
            baseFuelModel.fuelLevel = data
            baseFuelModel.recordIDFromDevice = Int64(index)
            dataSource.append(baseFuelModel)
        }
        RealmHelper.addObjects(by: dataSource)
    }

     func initializeRootViewController() -> ESTabBarController {
        let tabBarController = ESTabBarController()
        let v1 = BaseNavigationController.init(rootViewController: HomeViewController())
        let v2 = BaseNavigationController.init(rootViewController: StatisticalViewController())
        let v4 = BaseNavigationController.init(rootViewController: SettingViewController())
        
        v1.tabBarItem = ESTabBarItem.init(BaseBouncesContentView(), title: "Home".localized(), image: UIImage(named: "tab_home"), selectedImage: UIImage(named: "tab_home"))
        v2.tabBarItem = ESTabBarItem.init(BaseBouncesContentView(), title: "Statistics".localized(), image: UIImage(named: "tab_statistical"), selectedImage: UIImage(named: "tab_statistical"))
        v4.tabBarItem = ESTabBarItem.init(BaseBouncesContentView(), title: "Setting".localized(), image: UIImage(named: "tab_setting"), selectedImage: UIImage(named: "tab_setting"))
        
        tabBarController.viewControllers = [v1, v2,v4]
        return tabBarController
    }
}

