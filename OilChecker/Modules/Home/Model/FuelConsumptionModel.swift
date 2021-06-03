//
//  FuelConsumptionModel.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/30.
//

import UIKit
import RealmSwift

class FuelConsumptionModel: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var deviceID = ""
    @objc dynamic var recordIDFromDevice: Int64 = 0
    @objc dynamic var consumption : Double = 0.0
    @objc dynamic var recordCount: Int64 = 0
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}
extension SettingManager{
    func updateFuelConsumptionModel(_ data: FuelConsumptionModel){
    
        if data.id.isEmpty {
            try! realm.write{
                realm.add(data)
            }
        }else{
            try! realm.write{
                realm.add(data, update: .modified)
            }
        }
    }
    
    func deleteFuelConsumptionModel(_ modelID: String){
            
        let model = realm.object(ofType: FuelConsumptionModel.self, forPrimaryKey: modelID)
        guard model != nil else {
            return
        }
        try! realm.write{
            model?.isDeleted = true
        }
    }
}
