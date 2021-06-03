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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializeApp()

//        let bytess = [UInt8]("FFE0".utf8)
//        var buf : [UInt8] = Array("FFE0".utf8)
//        
//        let bufString = NSUUID.init(uuidBytes: buf)
//
//        let stringUUID = CBUUID.init(string: "FFE0")
//        let data: Data = stringUUID.data
//        let uuid = stringUUID.uuidString
//        let uuidString = NSUUID.init(uuidBytes: data.bytes)
////        let stringUUID = CBUUID.init(string: "FFE0")
//        var sValue = swapInt(0xFFE0)
//        let sData = NSData.init(bytes: &sValue, length: 2)
//        let s = Data.init(bytes: &sValue, count: 2)
//        
//        let sssss = Data.init(bytes: bytess, count: 2)

        
//        let ssss = UUID
        
//        let serviceUUID = CBUUID.init(data: s)
//        syncEngine = SyncEngine(objects: [
//                   SyncObject(type: Dog.self),
//                   SyncObject(type: Cat.self),
//                   SyncObject(type: Person.self)
//               ])
//        application.registerForRemoteNotifications()
        
        addFakeData()
//        addFakeReFuelData()
        logger.info("\(NSHomeDirectory())")
        return true
    }
    
    func swapInt(_ data: UInt16) -> UInt16 {
        var temp = data << 8
        temp |= data >> 8
        return temp
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
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.window?.makeKeyAndVisible()
    }
    
    func addFakeReFuelData() {
        
        let startDate = DateInRegion.init(Date(), region: .UTC).date.nearestHour - 500.hours//getDataRegion().date.nearestHour - 500.hours

        for index in 1...100 {
            let data = Double(arc4random_uniform(100))+50
            let fuelMode = RefuelRecordModel.init()
            fuelMode.deviceID = "999"
            fuelMode.refuelLevel = data
            SettingManager.shared.updateRefuelRecordModel(fuelMode)
        }

        for index in 1...100 {
            let data = Double(arc4random_uniform(100))+50
            let fuelMode = FuelConsumptionModel.init()
            fuelMode.deviceID = "999"
            fuelMode.consumption = data
            SettingManager.shared.updateFuelConsumptionModel(fuelMode)
        }
        
    }

    func addFakeData() {
        
        for index in 1...1000 {
            let data = Double(arc4random_uniform(100))+50
            let baseFuelModel = BaseFuelDataModel.init()
            baseFuelModel.deviceID = "999"
            baseFuelModel.fuelLevel = data
            baseFuelModel.recordIDFromDevice = Int64(index)
            SettingManager.shared.updateBaseFuelDataModel(baseFuelModel)
            
        }

        
//        for index in 1...10 {
//            let data = Double(arc4random_uniform(100))
//            let date = startDate + (index*2).hours
//            let malfuntion = MalfunctionModel.init()
//            malfuntion.deviceID = "999"
//            malfuntion.mcode = data.toString()
//            malfuntion.mName = "device error"
//            malfuntion.mtime = date
//            SettingManager.shared.updateMalfunctionInfo(malfuntion)
//        }
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

