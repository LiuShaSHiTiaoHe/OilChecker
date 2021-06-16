//
//  UserDefaultsKeys.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/26.
//

import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    var username: DefaultsKey<String?> { .init("username") }
    var launchCount: DefaultsKey<Int> { .init("launchCount", defaultValue: 0) }
    
    var currentCarDeviceID: DefaultsKey<String?> { .init("currentCarDeviceID", defaultValue: "") }
    
}
