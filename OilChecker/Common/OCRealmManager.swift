//
//  OCRealmManager.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/31.
//

import UIKit
import RealmSwift
class OCRealmManager: NSObject {

    static let instance:OCRealmManager = OCRealmManager()
    static func shared()-> OCRealmManager{
        return instance ;
    }
    
    private override init() {
        
    }
    
    private var realm:Realm = try! Realm()

    //MARK: construct
    /// 配置realm，当需要切换数据库的时候配置，例如，切换用户切换数据库，如果不配置那么是默认的
    ///
    /// - Parameter realmId: 数据库id
    func configRealm(realmId:String){
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(realmId).realm")
        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()
    }
    
    func realmGet() -> Realm {
        return realm
    }
    
    //MARK: add
    
    /// 添加一个
    ///
    /// - Parameter object: 添加元素
    func realmAdd(object:Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    /// 添加多个
    ///
    /// - Parameter objects: 添加数组
    func realmAdds(objects:Array<Object>) {
        try! realm.write {
            realm.add(objects)
        }
    }
    
    //MARK: delete
    
    /// 删除一个
    ///
    /// - Parameter object: 删除元素
    func realmDelete(object:Object) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    /// 删除多个
    ///
    /// - Parameter objects: 元素数组
    func realmDeletes(objects:Array<Object>) {
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    /// 条件删除
    ///
    /// - Parameters:
    ///   - object: 元素类型
    ///   - predicate: 条件
    func realmDeletesWithPredicate(object:Object.Type,predicate:NSPredicate) {
        
        let results:Array<Object> = self.realmQueryWithParameters(object: object, predicate: predicate)
        if results.count > 0 {
            try! realm.write {
                realm.delete(results)
            }
        }
    }
    
    /// 删除该类型所有
    ///
    /// - Parameter object: 元素类型
    func realmDeleteTypeList(object:Object.Type) {
        let objListResults = self.realmQueryWithType(object:object)
        if objListResults.count > 0 {
            try! realm.write {
                realm.delete(objListResults)
            }
        }
    }
    
    /// 删除当前数据库所有
    func realmDeleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    //MARK: update
    /// 更新元素(元素必须有主键)
    ///
    /// - Parameter object: 要更新的元素
    func realmUpdte(object:Object) {
        try! realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    /// 更新元素集合（元素必须有主键）
    ///
    /// - Parameter objects: 元素集合（集合内元素所有属性都要有值）
    func realmUpdtes(objects:Array<Object>) {
        try! realm.write {
            realm.add(objects, update: .modified)
        }
    }
    
    
    /// 更新操作 -> 对于realm搜索结果集当中的元素，在action当中直接负值即可修改
    ///
    /// - Parameter action:操作
    func realmUpdateWithTranstion(action:(Bool)->Void){
        try! realm.write {
            action(true)
        }
    }
    
    //MARK: query
    
    /// 查询元素
    ///
    /// - Parameters:
    ///   - object: 元素类型
    /// - Returns: 查询结果
    func realmQueryWith(object:Object.Type) ->Array<Object> {
        let results = self.realmQueryWithType(object: object)
        var resultsArray = Array<Object>()
        if results.count > 0 {
            for i in 0...results.count-1{
                resultsArray.append(results[i])
            }
        }
        return resultsArray
    }
    
    /// 查询元素
    ///
    /// - Parameters:
    ///   - object: 元素类型
    ///   - predicate: 查询条件
    /// - Returns: 查询结果
    func realmQueryWithParameters(object:Object.Type,predicate:NSPredicate) ->Array<Object> {
        let results = self.realmQueryWith(object: object, predicate: predicate)
        var resultsArray = Array<Object>()
        if results.count > 0 {
            for i in 0...results.count-1{
                resultsArray.append(results[i])
            }
        }
        return resultsArray
    }
    
    /// 分页查询
    ///
    /// - Parameters:
    ///   - object: 查询类型
    ///   - fromIndex: 起始页
    ///   - pageSize: 每页多少个
    /// - Returns: 查询结果
    func realmQueryWithParametersPage(object:Object.Type,fromIndex:Int,pageSize:Int) -> Array<Object> {
        
        let results = self.realmQueryWithType(object: object)
        var resultsArray = Array<Object>()
        if results.count <= pageSize*(fromIndex - 1) || fromIndex <= 0 {
            return resultsArray
        }
        if results.count > 0 {
            for i in pageSize*(fromIndex - 1)...fromIndex*pageSize-1{
                resultsArray.append(results[i])
            }
        }
        return resultsArray
        
    }
    
    /// 条件排序查询
    ///
    /// - Parameters:
    ///   - object: 查询类型
    ///   - predicate: 查询条件
    ///   - sortedKey: 排序key
    ///   - isAssending: 是否升序
    /// - Returns: 查询结果
    func realmQueryWithParametersAndSorted(object:Object.Type,predicate:NSPredicate,sortedKey:String,isAssending:Bool)->Array<Object>{
        
        let results = self.realmQueryWithSorted(object: object, predicate: predicate, sortedKey: sortedKey, isAssending: isAssending)
        var resultsArray = Array<Object>()
        if results.count > 0 {
            for i in 0...results.count-1{
                resultsArray.append(results[i])
            }
        }
        return resultsArray
        
    }
    
    ///  分页条件排序查询
    ///
    /// - Parameters:
    ///   - object: 查询类型
    ///   - predicate: 查询条件
    ///   - sortedKey: 排序key
    ///   - isAssending: 是否升序
    ///   - fromIndex: 起始页
    ///   - pageSize: 每页多少个
    /// - Returns: 查询结果
    func realmQueryWithParametersAndSortedAndPaged(object:Object.Type,predicate:NSPredicate,sortedKey:String,isAssending:Bool,fromIndex:Int,pageSize:Int)->Array<Object>{
        
        let results = self.realmQueryWithSorted(object: object, predicate: predicate, sortedKey: sortedKey, isAssending: isAssending)
        var resultsArray = Array<Object>()
        
        if results.count <= pageSize*(fromIndex - 1) || fromIndex <= 0 {
            return resultsArray
        }
        
        if results.count > 0 {
            for i in pageSize*(fromIndex - 1)...fromIndex*pageSize-1{
                resultsArray.append(results[i])
            }
        }
        return resultsArray
        
    }
    
    
    //MARK: private method
    
    /// 按类型查询
    ///
    /// - Parameter object: 查询元素类型
    /// - Returns: 查询结果
    private func realmQueryWithType(object:Object.Type) -> Results<Object>{
        return realm.objects(object)
    }
    
    /// 条件查询
    ///
    /// - Parameters:
    ///   - object: 查询元素类型
    ///   - predicate: 查询条件
    /// - Returns: 查询结果
    private func realmQueryWith(object:Object.Type,predicate:NSPredicate) ->Results<Object>{
        return realm.objects(object).filter(predicate)
    }
    
    /// 条件排序查询
    ///
    /// - Parameters:
    ///   - object: 查询类型
    ///   - predicate: 查询条件
    ///   - sortedKey: 排序key
    ///   - isAssending: 是否升序
    /// - Returns: 查询结果
    private func realmQueryWithSorted(object:Object.Type,predicate:NSPredicate,sortedKey:String,isAssending:Bool)->Results<Object>{
        return realm.objects(object).filter(predicate)
            .sorted(byKeyPath: sortedKey, ascending: isAssending)
    }
    
}
