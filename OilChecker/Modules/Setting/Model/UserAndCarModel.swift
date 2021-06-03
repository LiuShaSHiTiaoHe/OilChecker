//
//  UserAndCarModel.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/23.
//

import Foundation
import CloudKit
import IceCream
import RealmSwift

class UserAndCarModel: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var deviceID = ""
    @objc dynamic var carNumber = ""
    @objc dynamic var fuelTankWidth: Float = 0.0
    @objc dynamic var fuelTankLength: Float = 0.0
    @objc dynamic var fuelTankHeight: Float = 0.0
    @objc dynamic var voltage: Int = 1552
    @objc dynamic var createTime = Date()
    @objc dynamic var isDeleted = false
    
    
    override class func primaryKey() -> String? {
        return "id"
    }

}

extension UserAndCarModel: CKRecordRecoverable {
    
}

extension UserAndCarModel: CKRecordConvertible {
    
}


protocol SettingManagerRealmNotificationDelegate {
    func UpdateUserCarComplete()
    func UpdateMalfunctionInfoComplete()
    func updateFuelLevelComplete()
    
}

extension SettingManagerRealmNotificationDelegate {
    func UpdateUserCarComplete(){}
    func UpdateMalfunctionInfoComplete(){}
    func updateFuelLevelComplete(){}
}



class SettingManager: NSObject {
    
    let realm = try! Realm()
    var delegate: SettingManagerRealmNotificationDelegate?
    static let shared = SettingManager()
}

extension SettingManager {
    
    func updateUserCarInfo(_ data: UserAndCarModel){
        
        let token = realm.observe { notification, realm in
            self.delegate?.UpdateUserCarComplete()
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
    
    func deleteUserCar(_ modelID: String){
            
        let model = realm.object(ofType: UserAndCarModel.self, forPrimaryKey: modelID)
        guard model != nil else {
            return
        }
        let token = realm.observe { notification, realm in
            self.delegate?.UpdateUserCarComplete()
        }
        try! realm.write{
            model?.isDeleted = true
        }
        token.invalidate()
    }
    
}
