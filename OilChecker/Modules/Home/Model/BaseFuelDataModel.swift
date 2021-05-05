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
    @objc dynamic var rTime = Date()
    @objc dynamic var echoTimeInterval : Float = 0.0
    @objc dynamic var fuelLevel: Float = 0.0
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
