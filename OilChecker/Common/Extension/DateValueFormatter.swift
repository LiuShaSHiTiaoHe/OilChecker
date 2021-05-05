//
//  DateValueFormatter.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/2.
//

import UIKit
import Charts
import Foundation
import SwiftDate

public class DayDateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "HH"
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        logger.info("\(DateInRegion.init(seconds: value).toString(.custom(BaseDateFormatString)))")
//        logger.info("\(DateInRegion.init(seconds: value, region: .UTC))")
        return DateInRegion.init(seconds: value, region: .UTC).toString(.custom("HH:mm"))
//        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


public class WeekValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "MM-dd"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

public class MonthValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
