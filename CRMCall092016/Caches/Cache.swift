//
//  Cache.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/19/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import RealmSwift

class Cache {
    
    // MARK: - Initialzetion
    static let shareInstance = Cache()
    
    private var realm: Realm?
    
    init() {
        setupConfig()
        do {
            realm = try Realm()
        } catch let error {
            println("Cannot init Realm with error: \(error)")
        }
    }
    
    private func setupConfig() {
        
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.URLByDeletingLastPathComponent?
            .URLByAppendingPathComponent("CRMCall.realm")
        
        println("LINK Realm: \(config.fileURL))")
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: Conmon cache
    
    func cleanAll() {
        
    }
    
    // MARK: Caches UserInfo

    func userInfo(with info: [String: String]) {
        
        guard let realm = self.realm else {
            println("Cannot init Realm")
            return
        }
        
        let userInfo = Customer()
        
        if let idx = info["ID"] as String? {
            userInfo.idx = idx
        } else {
            userInfo.idx = "None"
        }
        
        if let userKey = info["USERKEY"] as String? {
            userInfo.userKey = userKey
        } else {
            userInfo.userKey = "None"
        }
        
        if let phone = info["PHONE"] as String? {
            userInfo.phone = phone
        } else {
            userInfo.phone = "0"
        }
        
        if let userName = info["USERNAME"] as String? {
            userInfo.userName = userName
        } else {
            userInfo.userName = "None"
        }
        
        if let email = info["EMAIL"] as String? {
            userInfo.email = email
        } else {
            userInfo.email = "None"
        }
        
        if let sex = info["SEX"] as String? {
            userInfo.sex = sex
        } else {
            userInfo.sex = "0"
        }
        
        if let cacheProduct = info["CACHE_PRODUCT"] as String? {
            userInfo.cacheProduct = cacheProduct
        } else {
            userInfo.cacheProduct = "None"
        }
        
        if let cachePurpose = info["CACHE_PURPOSE"] as String? {
            userInfo.cachePurpose = cachePurpose
        } else {
            userInfo.cachePurpose = "None"
        }
        
        if !realm.refresh() {
            do {
                let _ = try realm.write {
                    realm.add(userInfo, update: true)
                }
            } catch let e {
                println("Insert User with Error: \(e)")
            }
        }
    }
    
    func getUserInfo() -> Results<Customer>? {
        
        guard let realm = self.realm else {
            println("Cannot init Realm")
            return nil
        }
        
        return realm.objects(Customer.self)
    }
    
    func cleanInfoUser() {
        
        guard let realm = self.realm else {
            println("Cannot init Realm")
            return
        }
        
        guard let userInfo = getUserInfo() else {
            println("Cannot clean caches infor user")
            return
        }
        
        do {
            try realm.write{
                realm.delete(userInfo)
            }
        } catch let error {
            println("clean User info with error: \(error)")
        }
    }
    
    // MARK: Caches Customer info
    
    func customerInfo(with info: [String: String], staffList: List<Staff>, productList: List<Product>) {
        
        guard let realm = self.realm else {
            println("Cannot init Realm")
            return
        }
        
        let customerInfo = UserInfo()
        
        if let idx = info["ID"] as String? {
            customerInfo.idx = idx
        } else {
            customerInfo.idx = "None"
        }
        
        if let category = info["CATEGORY"] as String? {
            customerInfo.category = category
        } else {
            customerInfo.category = "None"
        }
        
        if let cn = info["CN"] as String? {
            customerInfo.cn = cn
        } else {
            customerInfo.cn = "000"
        }
        
        if let code = info["CODE"] as String? {
            customerInfo.code = code
        } else {
            customerInfo.code = "000-000-000"
        }
        
        if let name = info["NAME"] as String? {
            customerInfo.name = name
        } else {
            customerInfo.name = "None"
        }
        
        if let parentCN = info["PARENT_CN"] as String? {
            customerInfo.parentCN = parentCN
        } else {
            customerInfo.parentCN = "0"
        }
        
        if let parentCode = info["PARENT_CODE"] as String? {
            customerInfo.parentCode = parentCode
        } else {
            customerInfo.parentCode = "000-000-000"
        }
        
        if let parentName = info["PARENT_NAME"] as String? {
            customerInfo.parentName = parentName
        } else {
            customerInfo.parentName = "None"
        }
        
        if let phone = info["PHONE"] as String? {
            customerInfo.phone = phone
        } else {
            customerInfo.phone = "0"
        }
        
        if let phoneType = info["PHONETYPE"] as String? {
            customerInfo.phoneType = phoneType
        } else {
            customerInfo.phoneType = "0"
        }
        
        if let rating = info["RATING"] as String? {
            customerInfo.rating = rating
        } else {
            customerInfo.rating = "none rating"
        }

        if let type = info["TYPE"] as String? {
            customerInfo.rating = type
        } else {
            customerInfo.rating = "none type"
        }
        
        for customer in productList {
            customerInfo.products.append(customer)
        }
        
        for staff in staffList {
            customerInfo.staffs.append(staff)
        }

        if !realm.refresh() {
            do {
                let _ = try realm.write {
                    realm.add(customerInfo, update: true)
                }
            } catch let e {
                println("Insert customer info with Error: \(e)")
            }
        }
    }
    
    func getCustomerInfo() -> Results<UserInfo>? {
        
        guard let realm = self.realm else {
            println("Cannot init Realm")
            return nil
        }
        
        return realm.objects(UserInfo.self)
    }
    
    func cleanCustomerInfo() {
        
        guard let realm = self.realm else {
            println("Cannot init Realm")
            return
        }
        
        guard let userInfo = getCustomerInfo() else {
            println("Cannot clean caches customer info")
            return
        }
        
        do {
            try realm.write{
                realm.delete(userInfo)
            }
        } catch let error {
            println("clean customers info with error: \(error)")
        }
    }
    
    // MARK: Caches Staff
    
    
    
    // MARK: Caches Product

}
