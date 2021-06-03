//
//  FuelLevelModel.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/30.
//

import UIKit
import RealmSwift

class RefuelRecordModel: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var deviceID = ""
    @objc dynamic var recordIDFromDevice: Int64 = 0
    @objc dynamic var refuelLevel: Double = 0.0
    @objc dynamic var fuelCount: Int64 = 0
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension SettingManager{
    func updateRefuelRecordModel(_ data: RefuelRecordModel){
        
        let token = realm.observe { notification, realm in
            self.delegate?.updateFuelLevelComplete()
        }
        
        if data.id.isEmpty {
            try! realm.write{
                realm.add(data)
            }
        }else{
            try! realm.write{
                realm.add(data, update: .modified)
            }
        }
        token.invalidate()
    }
    
    func deleteRefuelRecordModel(_ modelID: String){
        let model = realm.object(ofType: RefuelRecordModel.self, forPrimaryKey: modelID)
        guard model != nil else {
            return
        }
        let token = realm.observe { notification, realm in
            self.delegate?.updateFuelLevelComplete()
        }
        try! realm.write{
            model?.isDeleted = true
        }
        token.invalidate()
    }
}

