//
//  GlobalConfigure.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/21.
//

import UIKit
import Logging
import SwiftDate
//import ClockKit
//import IceCream

let logger = Logger(label: "com.OilChecker.main")
let BaseDateFormatString = "yyyy-MM-dd HH:mm:ss"

func getDataRegion() -> DateInRegion {
    let dateRegion = DateInRegion.init(Date(), region: .UTC)
    return dateRegion
}
//var syncEngine: SyncEngine?

//let settingTableData: Dictionary<String, Array<Dictionary<String, String>>> = ["Section0": [["name": "User", "icon": "icon_baseinfo"], ["name": "Car", "icon": "icon_car"]], "Section1": [["name": "Equipment Malfunction", "icon": "icon_malfunction"]]]

let settingTableData: Dictionary<String, Array<Dictionary<String, String>>> = ["Section0": [ ["name": "Car", "icon": "icon_car"]], "Section1": [["name": "Equipment Malfunction", "icon": "icon_malfunction"]]]


enum MalfuntionType: Int {
    case type1 = 100
    case type2 = 101
    case type3 = 102
    case type4 = 103
    case type5 = 104

    var errorName: String {
        switch self {
        case .type1:
            return "error1"
        case .type2:
            return "error2"
        case .type3:
            return "error3"
        case .type4:
            return "error4"
        case .type5:
            return "error5"
        }
    }
    

    
    
}

