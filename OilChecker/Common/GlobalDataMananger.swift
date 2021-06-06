//
//  GlobalDataMananger.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/5.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults

class GlobalDataMananger: NSObject {

    static let shared = GlobalDataMananger()
//    private var realm:Realm = try! Realm()

    func fuelDataProcessor(_ deviceID: String) {
        
        let dataSource = RealmHelper.queryObject(objectClass: BaseFuelDataModel(), filter: "deviceID = '\(deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}
        if dataSource.count == 0 {
            return
        }
        var refuelDataArray: Array<Dictionary<String, String>> = []
        var consumptionDataArray: Array<Dictionary<String, String>> = []

        for index in 0 ... dataSource.count-2 {
            guard index+1 < dataSource.count else {
                return
            }
            let first = dataSource[index]
            let second = dataSource[index+1]
            var refuelDic: Dictionary<String, String> = [:]
            var consumptionDic: Dictionary<String, String> = [:]
            
            refuelDic.updateValue(first.recordIDFromDevice.string, forKey: "id")
            consumptionDic.updateValue(first.recordIDFromDevice.string, forKey: "id")

            if second.fuelLevel > first.fuelLevel {
                let refuelData = second.fuelLevel - first.fuelLevel
                refuelDic.updateValue(refuelData.string, forKey: "refuel")
                consumptionDic.updateValue("0", forKey: "consumpiton")
            }else{
                let consumptionData = first.fuelLevel - second.fuelLevel
                refuelDic.updateValue("0", forKey: "refuel")
                consumptionDic.updateValue(consumptionData.string, forKey: "consumpiton")
            }
            refuelDataArray.append(refuelDic)
            consumptionDataArray.append(consumptionDic)
        }
        
        if refuelDataArray.count > 0 {
            let array = refuelDataArray.filter { dic in
                let refuel = dic["refuel"]
                return refuel != "0"
            }
            RealmHelper.clearTableClass(objectClass: RefuelRecordModel())
            var refuelDataSource: [RefuelRecordModel] = []
            for (index, item) in array.enumerated() {
                let refuleModel = RefuelRecordModel()
                refuleModel.deviceID = deviceID
                refuleModel.recordIDFromDevice = Int64(index)//Int64(item["id"]!)!
                refuleModel.refuelLevel = item["refuel"]?.double() ?? 0.0
                refuleModel.fuelCount = 1
                refuelDataSource.append(refuleModel)
            }
            RealmHelper.addObjects(by: refuelDataSource)
            
        }
        
        if consumptionDataArray.count > 0 {
            let array = consumptionDataArray.filter { dic in
                let refuel = dic["consumpiton"]
                return refuel != "0"
            }
            RealmHelper.clearTableClass(objectClass: FuelConsumptionModel())
            var consumptionDataSource: [FuelConsumptionModel] = []

            for (index, item) in array.enumerated() {
                let consumptionModel = FuelConsumptionModel()
                consumptionModel.deviceID = deviceID
                consumptionModel.recordIDFromDevice = Int64(index)//Int64(item["id"]!)!
                consumptionModel.consumption = item["consumpiton"]?.double() ?? 0.0
                consumptionModel.recordCount = 1
                consumptionDataSource.append(consumptionModel)
            }
            RealmHelper.addObjects(by: consumptionDataSource)
        }

    }
    
    func getAverageConsumption(_ deviceID: String) -> String {
        let model = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(deviceID)'").last?.consumption.string
        return model ?? "0"
    }
    
    
    func getCurrentDeviceInfo(_ deviceID: String) -> UserAndCarModel? {
        if Defaults[\.currentCarID] != "" {
            return RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(deviceID)'").first
        }else{
            return nil
        }
    }
}
