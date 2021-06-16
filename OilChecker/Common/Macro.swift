//
//  Macro.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/20.
//

import Foundation
import SwifterSwift


// keyWindow
let KeyWindow : UIWindow = UIApplication.shared.keyWindow!

/// 屏幕的宽
let kScreenWidth = UIScreen.main.bounds.size.width
/// 屏幕的高
let kScreenHeight = UIScreen.main.bounds.size.height

let kIs_iphone = (UIDevice().userInterfaceIdiom == .phone)

let kIs_iPhoneX = (kScreenWidth >= 375.0 && kScreenHeight >= 812.0 && kIs_iphone)

/// 间距
let kMargin: CGFloat = 20.0

let kCellMargin: CGFloat = 10.0

/// 圆角
let kCornerRadius: CGFloat = 10.0
/// 线宽
let klineWidth: CGFloat = 0.5
/// 双倍线宽
let klineDoubleWidth: CGFloat = 1.0
/// 状态栏高度
let kStateHeight : CGFloat = getStatusBarHeight()
/// 标题栏高度
let kTitleHeight : CGFloat = 44.0
/// 状态栏和标题栏高度
let kTitleAndStateHeight : CGFloat = kStateHeight + kTitleHeight
/// 底部导航栏高度
let kTabBarHeight: CGFloat =  (kIs_iphone ? (kIs_iPhoneX ? 83 : 49) : 49)  //(UIScreen.main.bounds.size.height >= 812 ? 83 : 49) as CGFloat
/// 底部按钮高度
let kBottomTabbarHeight : CGFloat = 49.0



func getStatusBarHeight() -> CGFloat {
   var statusBarHeight: CGFloat = 0
   if #available(iOS 13.0, *) {
       let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
       statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
   } else {
       statusBarHeight = UIApplication.shared.statusBarFrame.height
   }
   return statusBarHeight
}

/// 按钮高度
let kUIButtonHeight : Float = 44.0

////sheetView 常量定义
///分割线高度
let kLineHeight : CGFloat = 0.5
/// 间距
let kSheetMargin: CGFloat = 6.0
/// sheetView cell高度
let kCellH : CGFloat = 45
/// sheetView 最大高度
let kSheetViewMaxH : CGFloat = kScreenHeight * 0.7
/// sheetView 宽度
let kSheetViewWidth  = kScreenWidth - kSheetMargin * 2





let kThemeColor = UIColor.init(hex: 0x5944DD)!
/// 通用背景颜色
let kBackgroundColor : UIColor = UIColor.init(hex: 0xf2f2f2)!
/// 导航栏背景颜色
let kThemeGreenColor : UIColor = UIColor.init(hex: 0x2dae99)!
let kNavBarColor : UIColor = UIColor.init(hex: 0x5944DD)!
let kOrangeColor: UIColor = UIColor.init(hex: 0xfe7f4a)!
let kRedAlphaColor: UIColor = UIColor.init(hex: 0xf53333, transparency: 0.6)!
let kGreenAlphaColor : UIColor = UIColor.init(hex: 0x2dae99, transparency: 0.6)!


/// 黑色字体颜色
let kBlackFontColor : UIColor = UIColor.init(hex: 0x1d1d1d)!
let kSecondBlackColor: UIColor = UIColor.init(hex: 0x515151)!
/// 深灰色字体颜色
let kHeightGaryFontColor : UIColor = UIColor.init(hex: 0x797979)!
/// 灰色字体颜色
let kGaryFontColor : UIColor = UIColor.init(hex: 0xaeaeae)!
/// 黄色字体颜色
let kYellowFontColor : UIColor = UIColor.init(hex: 0xfda007)!
/// 浅灰色字体颜色
let kLightGaryFontColor : UIColor = UIColor.init(hex: 0xdcdcdc)!
/// 红色字体颜色
let kRedFontColor : UIColor = UIColor.init(hex: 0xf53333)!
/// 绿色字体颜色
let kGreenFontColor : UIColor = UIColor.init(hex: 0x2dae99)!
/// 灰色线的颜色
let kGrayLineColor : UIColor = UIColor.init(hex: 0xdcdcdc)!
/// btn不可点击背景色
let kBtnNoClickBGColor : UIColor = UIColor.init(hex: 0xd8d8d8)!
/// btn可点击背景色
let kBtnClickBGColor : UIColor = UIColor.init(hex: 0x2dae99)!
/// btn可点击浅绿色背景色
let kBtnClickLightGreenColor : UIColor = UIColor.init(hex: 0x36dbc0)!
/// 系统白色
let kWhiteColor : UIColor = .white
/// 系统黑色
let kBlackColor : UIColor = .black

/// 字体常量
let k10Font = UIFont.systemFont(ofSize: 10.0)
let k12Font = UIFont.systemFont(ofSize: 12.0)
let k13Font = UIFont.systemFont(ofSize: 13.0)
let k14Font = UIFont.systemFont(ofSize: 14.0)
let k15Font = UIFont.systemFont(ofSize: 15.0)
let k16Font = UIFont.systemFont(ofSize: 16.0)
let k18Font = UIFont.systemFont(ofSize: 18.0)
let k20Font = UIFont.systemFont(ofSize: 20.0)

let k10BoldFont = UIFont.boldSystemFont(ofSize: 10)
let k12BoldFont = UIFont.boldSystemFont(ofSize: 12.0)
let k13BoldFont = UIFont.boldSystemFont(ofSize: 13.0)
let k14BoldFont = UIFont.boldSystemFont(ofSize: 14.0)
let k15BoldFont = UIFont.boldSystemFont(ofSize: 15.0)
let k18BoldFont = UIFont.boldSystemFont(ofSize: 18.0)
let k20BoldFont = UIFont.boldSystemFont(ofSize: 20.0)


let DefaultEmptyNumberString = "0.0"

let ServiceUUID = 0xFFE0
//let ServiceUUIDString = "0000FFE0-0000-1000-8000-00805F9B34FB"
let ServiceUUIDString = "FFE0"

let CharacteristicNotifyUUID = 0xFFE1
//let CharacteristicNotifyUUIDString = "0000FFE1-0000-1000-8000-00805F9B34FB"
let CharacteristicNotifyUUIDString = "FFE1"

let CharacteristicWriteUUID = 0xFFE2
//let CharacteristicWriteUUIDString = "0000FFE2-0000-1000-8000-00805F9B34FB"
let CharacteristicWriteUUIDString = "FFE2"

let DefualtDeviceID = 0x0000
let warningFuelChangedValue: Double = 5.0

let BabyChannelHomeIdentifier = "BabyChannelHomeIdentifier"
let BabyChannelScanViewIdentifier = "BabyChannelScanViewIdentifier"
let BabyChannelAddDeviceIdentifier = "BabyChannelAddDeviceIdentifier"


enum FuelCapacityState: String {
    case Unknown = "Unknown"
    case Normal =  "Normal"
    case Irregular = "Irregular"
}

extension Notification.Name {
    //更新视图
   static let SyncDateCompleteNotify = Notification.Name(rawValue:"updateHomeChartAndStatus")
}


let DigtesKeyboardHeight: CGFloat = 203
let DigtesKeyboardDeleteButtonWidth: CGFloat = 80
