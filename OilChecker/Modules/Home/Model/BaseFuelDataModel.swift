//
//  BaseFuelDataModel.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/2.
//

import UIKit
import RealmSwift

class BaseFuelDataModel: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var deviceID = ""
    @objc dynamic var recordIDFromDevice: Int64 = 0
    @objc dynamic var fuelLevel: Double = 0.0
    @objc dynamic var fueltankHeight: Double = 0.0
    @objc dynamic var fueltankWidth: Double = 0.0
    @objc dynamic var fueltankLength: Double = 0.0
    @objc dynamic var isFirstActive = false
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}
extension SettingManager{
    func updateBaseFuelDataModel(_ data: BaseFuelDataModel){
    
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
    
    func deleteBaseFuelDataModel(_ modelID: String){
            
        let model = realm.object(ofType: BaseFuelDataModel.self, forPrimaryKey: modelID)
        guard model != nil else {
            return
        }
        try! realm.write{
            model?.isDeleted = true
        }
    }
}
