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
    dynamic var phone = 0
    dynamic var userKey = ""
    dynamic var userName = ""
    dynamic var email = ""
    dynamic var sex = "0"
    dynamic var cacheProduct = "0"
    dynamic var cachePurpose = "0"
    
//    override static func primaryKey() -> String? {
//        return "idx"
//    }
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}


