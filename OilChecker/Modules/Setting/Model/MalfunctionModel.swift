//
//  MalfunctionModel.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import Foundation
import CloudKit
import IceCream
import RealmSwift

class MalfunctionModel: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var deviceID = ""
    @objc dynamic var name = ""
    @objc dynamic var code = ""
    @objc dynamic var mDescription = ""
    @objc dynamic var time = ""
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension MalfunctionModel: CKRecordRecoverable {
    
}

extension MalfunctionModel: CKRecordConvertible {
    
}

extension SettingManager{
    func updateMalfunctionInfo(_ data: MalfunctionModel){
        
        let token = realm.observe { notification, realm in
            self.delegate?.UpdateMalfunctionInfoComplete()
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
    
    func deleteMalfunctionInfo(_ modelID: String){
            
        let model = realm.object(ofType: MalfunctionModel.self, forPrimaryKey: modelID)
        guard model != nil else {
            return
        }
        let token = realm.observe { notification, realm in
            self.delegate?.UpdateMalfunctionInfoComplete()
        }
        try! realm.write{
            model?.isDeleted = true
        }
        token.invalidate()
    }
}
