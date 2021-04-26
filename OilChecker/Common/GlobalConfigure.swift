//
//  GlobalConfigure.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/21.
//

import UIKit
import Logging
//import ClockKit
import IceCream

let logger = Logger(label: "com.OilChecker.main")
var syncEngine: SyncEngine?

//let settingTableData: Dictionary<String, Array<Dictionary<String, String>>> = ["Section0": [["name": "User", "icon": "icon_baseinfo"], ["name": "Car", "icon": "icon_car"]], "Section1": [["name": "Equipment Malfunction", "icon": "icon_malfunction"]]]

let settingTableData: Dictionary<String, Array<Dictionary<String, String>>> = ["Section0": [ ["name": "Car", "icon": "icon_car"]], "Section1": [["name": "Equipment Malfunction", "icon": "icon_malfunction"]]]
