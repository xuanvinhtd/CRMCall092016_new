//
//  Cache.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/19/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift

class Cache {
    
    // MARK: - Initialzetion
    static let shareInstance = Cache()
    
    let realmQueue = dispatch_queue_create("CRMCall.Realm", nil)
    
    init() {
        setupConfig()
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
    
    // MARK: - COMMON
    
    func cleanAll() {
        
    }
    
    // MARK: - USERINFO
    
    func userInfo(with info: [String: String]) {
        
        let userInfo = Customer()
        
        if let idx = info["ID"] as String? {
            userInfo.idx = idx
        } else {
            userInfo.idx = ""
        }
        
        if let userKey = info["USERKEY"] as String? {
            userInfo.userKey = userKey
        } else {
            userInfo.userKey = ""
        }
        
        if let phone = info["PHONE"] as String? {
            userInfo.phone = phone
        } else {
            userInfo.phone = "0"
        }
        
        if let userName = info["USERNAME"] as String? {
            userInfo.userName = userName
        } else {
            userInfo.userName = ""
        }
        
        if let email = info["EMAIL"] as String? {
            userInfo.email = email
        } else {
            userInfo.email = ""
        }
        
        if let sex = info["SEX"] as String? {
            userInfo.sex = sex
        } else {
            userInfo.sex = "0"
        }
        
        if let cacheProduct = info["CACHE_PRODUCT"] as String? {
            userInfo.cacheProduct = cacheProduct
        } else {
            userInfo.cacheProduct = ""
        }
        
        if let cachePurpose = info["CACHE_PURPOSE"] as String? {
            userInfo.cachePurpose = cachePurpose
        } else {
            userInfo.cachePurpose = ""
        }
        
        dispatch_async(realmQueue) {
            do {
                let realm = try Realm()
                
                if !realm.refresh() {
                    do {
                        let _ = try realm.write {
                            realm.add(userInfo, update: true)
                        }
                    } catch let e {
                        println("Insert User with Error: \(e)")
                    }
                }
                
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
        
    }
    
    func getUserInfo() -> Results<Customer>? {
        
        var realm: Realm?
        var result: Results<Customer>?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                result = realm!.objects(Customer.self)
                
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
        
        return result
    }
    
    func cleanInfoUser() {
        
        guard let userInfo = getUserInfo() else {
            println("Cannot clean caches infor user")
            return
        }
        
        dispatch_async(realmQueue) {
            do {
                let realm = try Realm()
                
                do {
                    try realm.write{
                        realm.delete(userInfo)
                    }
                } catch let error {
                    println("clean User info with error: \(error)")
                }
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    // MARK: - CUSTOMER
    
    func customerInfo(with info: [String: String], staffList: List<Staff>?, productList: List<Product>?) {
        
        let customerInfo = UserInfo()
        
        if let idx = info["ID"] as String? {
            customerInfo.idx = idx
        } else {
            customerInfo.idx = ""
        }
        
        if let category = info["CATEGORY"] as String? {
            customerInfo.category = category
        } else {
            customerInfo.category = ""
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
            customerInfo.name = ""
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
            customerInfo.parentName = ""
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
            customerInfo.rating = ""
        }
        
        if let type = info["TYPE"] as String? {
            customerInfo.rating = type
        } else {
            customerInfo.rating = ""
        }
        
        if productList != nil {
            for customer in productList! {
                customerInfo.products.append(customer)
            }
        }
        
        if staffList != nil {
            for staff in staffList! {
                customerInfo.staffs.append(staff)
            }
        }
        
        dispatch_async(realmQueue) {
            do {
                let realm = try Realm()
                
                if !realm.refresh() {
                    do {
                        let _ = try realm.write {
                            realm.add(customerInfo, update: true)
                        }
                    } catch let e {
                        println("Insert customer info with Error: \(e)")
                    }
                }
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    func getCustomerInfo() -> Results<UserInfo>? {
        
        var realm: Realm?
        var result: Results<UserInfo>?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                result = realm!.objects(UserInfo.self)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
        
        return result
    }
    
    func getCustomerInfo(with predicate: NSPredicate, Result: ((Results<UserInfo>?) ->Void)){
        
        var realm: Realm?
        var data: Results<UserInfo>?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                data = realm!.objects(UserInfo.self).filter(predicate)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    func cleanCustomerInfo() {
        
        guard let userInfo = getCustomerInfo() else {
            println("Cannot clean caches customer info")
            return
        }
        
        dispatch_async(realmQueue) {
            do {
                let realm = try Realm()
                
                do {
                    try realm.write{
                        realm.delete(userInfo)
                    }
                } catch let error {
                    println("clean customers info with error: \(error)")
                }
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    // MARK: - TREE STAFF
    
    func staffTree(with info: [[String: AnyObject]]) {
        
        var idRoot = 0
        var idRootChild = 0
        var idChild = 0
        
        for root in info {
            
            let rootStaff = RootTree()
            rootStaff.idx = String(idRoot)
            
            if let name = root["title"] as? String {
                rootStaff.title = name
            }
            
            if let groupId = root["group_mng_id"] as? String {
                rootStaff.group_mng_id = groupId
            }
            
            if let isFolder = root["isFolder"] as? Bool {
                rootStaff.isFolder = isFolder
            }
            
            if let isLazy = root["isLazy"] as? Bool {
                rootStaff.isLazy = isLazy
            }
            
            idRoot += 1
            
            guard let children = root["children"] as? [[String: AnyObject]] else {
                continue
            }
            
            for _rootChild in children {
                
                let rootChild = RootChild()
                rootChild.idx = String(idRootChild)
                
                if let name = _rootChild["title"] as? String {
                    rootChild.title = name
                }
                
                if let groupId = _rootChild["group_mng_id"] as? String {
                    rootChild.group_mng_id = groupId
                }
                
                if let isFolder = _rootChild["isFolder"] as? Bool {
                    rootChild.isFolder = isFolder
                }
                
                if let isLazy = _rootChild["isLazy"] as? Bool {
                    rootChild.isLazy = isLazy
                }
                
                idRootChild += 1
                
                guard let _children = _rootChild["children"] as? [[String: AnyObject]] else {
                    rootStaff.rootchildren.append(rootChild)
                    continue
                }
                
                for achild in _children {
                    
                    let child = ChildTree()
                    child.idx = String(idChild)
                    
                    if let name = achild["title"] as? String {
                        child.title = name
                    }
                    
                    if let name = achild["name_jp"] as? String {
                        child.name_jp = name
                    }
                    
                    if let nameCh = achild["name_ch"] as? String {
                        child.name_ch = nameCh
                    }
                    
                    if let nameChSimp = achild["name_ch_simp"] as? String {
                        child.name_ch_simp = nameChSimp
                    }
                    
                    if let userNo = achild["user_no"] as? String {
                        child.user_no = userNo
                    }
                    
                    if let userGroup = achild["user_group_id"] as? String {
                        child.user_group_id = userGroup
                    }
                    
                    if let localphone = achild["localphone"] as? String {
                        child.localphone = localphone
                    }
                    
                    if let groupId = achild["group_id"] as? String {
                        child.group_id = groupId
                    }
                    
                    if let isFolder = achild["isFolder"] as? Bool {
                        child.isFolder = isFolder
                    }
                    
                    if let isLazy = achild["isLazy"] as? Bool {
                        child.isLazy = isLazy
                    }
                    
                    rootChild.childrens.append(child)
                    idChild += 1
                }
                
                rootStaff.rootchildren.append(rootChild)
            }
            
            dispatch_async(realmQueue) {
                do {
                    let realm = try Realm()
                    
                    if !realm.refresh() {
                        do {
                            let _ = try realm.write {
                                realm.add(rootStaff, update: true)
                            }
                        } catch let e {
                            println("Insert Staff Tree with Error: \(e)")
                        }
                    }
                } catch let error {
                    println("Cannot init Realm with error: \(error)")
                }
            }
        }
    }
    
    func getStaffTree(Result: ((Results<RootTree>?)->Void)) {
        var realm: Realm?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                let data = realm!.objects(RootTree.self)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    func getStaffTree(with predicate: NSPredicate, Result: ((Results<RootTree>?) ->Void)){
        
        var realm: Realm?
        var data: Results<RootTree>?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                data = realm!.objects(RootTree.self).filter(predicate)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    func cleanStaffTree() {
        
        getStaffTree { (data) in
            guard let tree = data else {
                println("Cannot clean caches tree staff")
                return
            }
            
            dispatch_async(self.realmQueue) {
                do {
                    let realm = try Realm()
                    
                    do {
                        try realm.write{
                            realm.delete(tree)
                        }
                    } catch let error {
                        println("clean tree staff with error: \(error)")
                    }
                } catch let error {
                    println("Cannot init Realm with error: \(error)")
                }
            }
        }
    }
    
    // MARK: - PRODUCT
    
    func productCN(with info: [[String: AnyObject]]) {
        for dict in info {
            let product = ProductCN()
            if let idx = dict["product_id"] as? String {
                product.idx = idx
            }
            
            if let prodCode = dict["prod_code"] as? String {
                product.prodCode = prodCode
            }
            
            if let name = dict["name"] as? String {
                product.name = name
            }
            
            if let is_discontinue = dict["is_discontinue"] as? Bool {
                product.isDiscontinune = is_discontinue
            }
            
            dispatch_async(realmQueue) {
                do {
                    let realm = try Realm()
                    
                    if !realm.refresh() {
                        do {
                            let _ = try realm.write {
                                realm.add(product, update: true)
                            }
                        } catch let e {
                            println("Insert product with Error: \(e)")
                        }
                    }
                } catch let error {
                    println("Cannot init Realm with error: \(error)")
                }
            }
        }
    }
    
    func getProductCN(Result: ((Results<ProductCN>?)->Void)) {
        
        var realm: Realm?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                let data = realm!.objects(ProductCN.self)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    // MARK: - PURPOSE
    func purpose(with info: [[String: AnyObject]]) {
        for dict in info {
            let purpose = Purpose()
            if let idx = dict["id"] as? String {
                purpose.idx = idx
            }
            
            if let content = dict["content"] as? String {
                purpose.content = content
            }
            
            dispatch_async(realmQueue) {
                do {
                    let realm = try Realm()
                    
                    if !realm.refresh() {
                        do {
                            let _ = try realm.write {
                                realm.add(purpose, update: true)
                            }
                        } catch let e {
                            println("Insert purpose with Error: \(e)")
                        }
                    }
                } catch let error {
                    println("Cannot init Realm with error: \(error)")
                }
            }
        }
    }
    
    func getPurpose(Result: ((Results<Purpose>?)->Void)) {
        
        var realm: Realm?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                let data = realm!.objects(Purpose.self)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    // MARK: - RINGING
    func ringInfo(with info: [String: String]) {
        
        let ringInfo = RingIng()
        
        if let idx = info["CALLID"] as String? {
            ringInfo.callID = idx
        }
        
        if let from = info["FROM"] as String? {
            ringInfo.from = from
        }
        
        if let to = info["TO"] as String? {
            ringInfo.to = to
        }
        
        if let event = info["EVENT"] as String? {
            ringInfo.event = event
        }
        
        if let time = info["TIME"] as String? {
            ringInfo.time = time
        }
        
        if let direction = info["DIRECTION"] as String? {
            ringInfo.direction = direction
        } else {
            ringInfo.direction = "INBOUND"
        }
        
        dispatch_async(realmQueue) {
            do {
                let realm = try Realm()
                
                if !realm.refresh() {
                    do {
                        let _ = try realm.write {
                            realm.add(ringInfo, update: true)
                        }
                    } catch let e {
                        println("Insert ringInfo with Error: \(e)")
                    }
                }
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    func getRingInfo(Result: ((Results<RingIng>?)->Void)) {
        
        var realm: Realm?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                let data = realm!.objects(RingIng.self)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    func getRingInfo(with predicate: NSPredicate, Result: ((Results<RingIng>?) ->Void)) {
        
        var realm: Realm?
        var result: Results<RingIng>?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                result = realm!.objects(RingIng.self).filter(predicate)
                Result(result)
            } catch let error {
                Result(nil)
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
    // MARK: - PHONE TYPE
    func typePhone(with info: [String: String]) {
        
        for (key, value) in info {
            let typePhone = TypePhone()
            typePhone.idx = key
            typePhone.value = value
            
            dispatch_async(realmQueue) {
                do {
                    let realm = try Realm()
                    
                    if !realm.refresh() {
                        do {
                            let _ = try realm.write {
                                realm.add(typePhone, update: true)
                            }
                        } catch let e {
                            println("Insert typePhone with Error: \(e)")
                        }
                    }
                } catch let error {
                    println("Cannot init Realm with error: \(error)")
                }
            }
        }
    }
    
    func getPhoneType(Result: ((Results<TypePhone>?)->Void)) {
        var realm: Realm?
        
        dispatch_async(realmQueue) {
            do {
                realm = try Realm()
                
                let data = realm!.objects(TypePhone.self)
                Result(data)
            } catch let error {
                println("Cannot init Realm with error: \(error)")
            }
        }
    }
    
}
