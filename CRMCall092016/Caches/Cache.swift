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
    static let shareInstaince = Cache()
    
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
        
        if let userName = info["USERKEY"] as String? {
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

}
