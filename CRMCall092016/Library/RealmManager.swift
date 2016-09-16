//
//  RealmManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/16/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmManager {
    
    // MARK: Initialzation
    
//    private let realmQueue = dispatch_queue_create("CRMCall092016.realmQueue", DISPATCH_QUEUE_SERIAL)
//    
   // private static let realm = try! Realm()
    
    static func setupConfig() {
        
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.URLByDeletingLastPathComponent?
            .URLByAppendingPathComponent("habiro.realm")
        
        println("path: \(config.fileURL)")
        config.schemaVersion = 19
        config.migrationBlock = { migration, oldSchemaVersion in
        }
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: Caches data
    
    static func cacheUserInfo(with info: [String: String]) {
        do {
            let _ = try Realm()
        } catch let e {
            println("Cannot init Realm: \(e)")
        }
        
        guard let realm = try? Realm() else {
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
                    realm.add(userInfo)
                    //realm.add(userInfo, update: true)
                }
            } catch let e {
                println("Error: \(e)")
            }
        }
    }
    
    static func getUserInfo() -> Customer? {
        guard let realm = try? Realm() else {
            println("Cannot init Realm")
            return nil
        }
        
        return realm.objects(Customer.self).first
    }
    
    static func cleanCachesInfoUser() {
        guard let realm = try? Realm() else {
            println("Cannot init Realm")
            return
        }
        
        guard let userInfo = getUserInfo() else {
            println("Cannot clean caches infor user")
            return
        }
        let _ = try? realm.write{
            realm.delete(userInfo)
        }
    }
    
}

