//
//  User.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/8/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import RealmSwift

class Customer: Object {
    
    dynamic var idx = "0"
    dynamic var password = ""
    dynamic var phone = "0"
    dynamic var userKey = ""
    dynamic var userName = ""
    dynamic var email = ""
    dynamic var sex = "0"
    dynamic var cacheProduct = "0"
    dynamic var cachePurpose = "0"
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class Staff: Object {
    
    dynamic var no = "0"
    dynamic var cn = ""
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "no"
    }
    
    class func createList(with dataLst: [[String: String]]) -> List<Staff> {
        
        let staffLst = List<Staff>()

        for item in dataLst {
            let staff = Staff()
            
            if let no = item["STAFF_NO"] as String? {
                staff.no = no
            } else {
                staff.cn = "000"
            }
            
            if let name = item["STAFF_NAME"] as String? {
                staff.name = name
            } else {
                staff.name = "None staff name"
            }
            
            if let cn = item["STAFF_CN"] as String? {
                staff.cn = cn
            } else {
                staff.cn = "None staff cn"
            }
            
            staffLst.append(staff)
        }
        
        return staffLst
    }
}

class Product: Object {
    
    dynamic var cn = ""
    dynamic var name = ""
    dynamic var code = "0"
    
    override static func primaryKey() -> String? {
        return "code"
    }
    
    class func createList(with dataLst: [[String: String]]) -> List<Product> {
        
        let productLst = List<Product>()
        
        var idx = 0
        for item in dataLst {
            let product = Product()
            
            if let productCN = item["PRODUCT_CN"] as String? {
                product.cn = productCN
            } else {
                product.cn = "000"
            }
            
            if let name = item["PRODUCT_NAME"] as String? {
                product.name = name
            } else {
                product.name = "None product name"
            }
            
            if let no = item["PRODUCT_CODE"] as String? {
                product.code = no
            } else {
                product.code = "None product code"
            }
            
            idx += 1
            productLst.append(product)
        }
        
        return productLst
    }
}

class UserInfo: Object {
    
    dynamic var idx = "0"
    dynamic var category = ""
    dynamic var cn = ""
    dynamic var code = ""
    dynamic var name = "None name"
    dynamic var parentCN = ""
    dynamic var parentCode = ""
    dynamic var parentName = ""
    dynamic var phone = "0"
    dynamic var phoneType = "0:"
    dynamic var rating = ""
    dynamic var result = ""
    dynamic var type = ""
    let products = List<Product>()
    let staffs = List<Staff>()
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class RingIng: Object {
    dynamic var callID = "0"
    dynamic var from = ""
    dynamic var to = ""
    dynamic var event = ""
    dynamic var time = ""
    dynamic var direction = ""
    
    override static func primaryKey() -> String? {
        return "callID"
    }
}

class Purpose: Object {
    dynamic var idx = "0"
    dynamic var content = ""
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class ProductCN: Object {
    dynamic var idx = "0"
    dynamic var name = ""
    dynamic var prodCode = ""
    dynamic var isDiscontinune = false
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class RootTree: Object {
    dynamic var idx = "0"
    dynamic var title = ""
    dynamic var group_mng_id = ""
    dynamic var isFolder = true
    dynamic var isLazy = true
    let rootchildren = List<RootChild>()
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class RootChild: Object {
    dynamic var idx = "0"
    dynamic var title = ""
    dynamic var group_mng_id = ""
    dynamic var isFolder = true
    dynamic var isLazy = true
    let childrens = List<ChildTree>()
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class ChildTree: Object {
    dynamic var idx = "0"
    dynamic var title = ""
    dynamic var name_eng = ""
    dynamic var name_jp = ""
    dynamic var name_ch = ""
    dynamic var name_ch_simp = ""
    dynamic var user_no = ""
    dynamic var localphone = ""
    dynamic var group_id = ""
    dynamic var user_group_id = ""
    dynamic var isFolder = true
    dynamic var isLazy = true
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}

class TypePhone: Object {
    dynamic var idx = "0"
    dynamic var value = ""
    
    override static func primaryKey() -> String? {
        return "idx"
    }
}