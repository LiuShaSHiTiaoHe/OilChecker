//
//  OCRealmManager.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/31.
//

import UIKit
import RealmSwift
class RealmHelper: NSObject {
    
    static let shared  = RealmHelper()
    
    class func getRealm() -> Realm {
        let defaultRealm = try! Realm()
        return defaultRealm
    }
    
//    public class func configRealm() {
//        var config = Realm.Configuration()
//
//        // Use the default directory, but replace the filename with the username
//        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(RealmDBName).realm")
//
//        // Set this as the configuration used for the default Realm
//        Realm.Configuration.defaultConfiguration = config
//    }
    
}

///新增
extension RealmHelper {
    
    
    ///新增单条数据
    public class func addObject<T>(object: T){
        
        do {
            let defaultRealm = self.getRealm()
            try defaultRealm.write {
                defaultRealm.add(object as! Object)
            }
            print(defaultRealm.configuration.fileURL ?? "")
        } catch {}
        
    }
        
    /// 保存多条数据
    public class func addObjects<T>(by objects : [T]) -> Void {
        let defaultRealm = self.getRealm()
        try! defaultRealm.write {
            defaultRealm.add(objects as! [Object])
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
}

/// 删除
extension RealmHelper {
    
    
    /// 删除单条
    /// - Parameter object: 删除数据对象
    public class func deleteObject<T>(object: T?) {
        
        if object == nil {
            print("无此数据")
            return
        }
        
        do {
              let defaultRealm = self.getRealm()
              try defaultRealm.write {
                  defaultRealm.delete(object as! Object)
              }
        } catch {}
    }
    
    
    /// 删除多条数据
    /// - Parameter objects: 对象数组
    public class func deleteObjects<T>(objects: [T]?) {
        
        if objects?.count == 0 {
            print("无此数据")
            return
        }
        
        do {
              let defaultRealm = self.getRealm()
              try defaultRealm.write {
                  defaultRealm.delete(objects as! [Object])
              }
        } catch {}
    }

    
    /// 根据条件去删除单条/多条数据
    public class func deleteObjectFilter<T>(objectClass: T, filter: String?) {
        
        let objects = RealmHelper.queryObject(objectClass: objectClass, filter: filter)
        RealmHelper.deleteObjects(objects: objects)
        
    }
    
   
    /// 删除某张表
    /// - Parameter objectClass: 删除对象
      public class func clearTableClass<T>(objectClass: T) {
          
          do {
                let defaultRealm = self.getRealm()
                try defaultRealm.write {
                    defaultRealm.delete(defaultRealm.objects((T.self as! Object.Type).self))
                }
          } catch {}
      }
    
}

/// 查
extension RealmHelper {
    
    
    /// 查询数据
    /// - Parameters:
    ///   - objectClass: 当前查询对象
    ///   - filter: 查询条件
    class func queryObject <T> (objectClass: T, filter: String? = nil) -> [T]{
        
        let defaultRealm = self.getRealm()
        var results : Results<Object>
        
        if filter != nil {
                 
            results =  defaultRealm.objects((T.self as! Object.Type).self).filter(filter!)
        }
        else {
                 
            results = defaultRealm.objects((T.self as! Object.Type).self)
        }
        
        guard results.count > 0 else { return [] }
        var objectArray = [T]()
        for model in results{
           objectArray.append(model as! T)
        }
       
        return objectArray
        
    }
    
    
}

/// 更新
extension RealmHelper {
    ///更新单条数据
    public class func updateObject<T>(object: T) {
        
        do {
            let defaultRealm = self.getRealm()
            try defaultRealm.write {
                defaultRealm.add(object as! Object, update: .modified)
            }
        }catch{}
    }
    
//    public class func updateObjectAttribute<T>(object: T ,attribute:[String:Any]) {
//        let defaultRealm = self.getRealm()
//        try! defaultRealm.write {
//            let keys = attribute.keys
//             for keyString in keys {
//                object.setValue(attribute[keyString], forKey: keyString)
//            }
//        }
//    }
    
    
    /// 更新多条数据
    public class func updateObjects<T>(objects : [T]) {
        let defaultRealm = self.getRealm()
        try! defaultRealm.write {
            defaultRealm.add(objects as! [Object], update: .modified)
        }
    }
        
    /// 更新多条数据的某一个属性
    public class func updateObjectsAttribute<T>(objectClass : T ,attribute:[String:Any]) {
        let defaultRealm = self.getRealm()
        try! defaultRealm.write {
            let objects = defaultRealm.objects((T.self as! Object.Type).self)
            let keys = attribute.keys
             for keyString in keys {
                objects.setValue(attribute[keyString], forKey: keyString)
            }
        }
    }
    
}
