//
//  SWXMLHashManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/8/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import RealmSwift
import SWXMLHash


final class SWXMLHashManager {
    
    // MARK: - XML PARSER
    static func parseXMLToDictionary(withXML xmlData: String, Completion completion: (([String: String], CRMCallHelpers.TypeData) ->Void)?) {

        guard let completion = completion else {
            
            println("Not found closure COMPLETION")
            return
        }
        
        let xmlDocument = SWXMLHash.parse(xmlData)
        
        if let userDic = xmlDocument["XML"]["USER"]["LOGIN"].element {
            
            completion(userDic.attributes, CRMCallHelpers.TypeData.UserLogin)
            
            return
        }
        
        if let userDic = xmlDocument["XML"]["USER"]["LOGOUT"].element {
            
            completion(userDic.attributes, CRMCallHelpers.TypeData.UserLogout)
            
            return
        }
        
        if let dataDic = xmlDocument["XML"]["SERVERINFO"].element {
            
            completion(dataDic.attributes, CRMCallHelpers.TypeData.ServerInfo)
            
            return
        }
        
        if let dataDic = xmlDocument["XML"]["ALARM"]["LIVE"].element {
            
            completion(dataDic.attributes, CRMCallHelpers.TypeData.UserLive)
            
            return
        }
        
        if let dataDic = xmlDocument["XML"]["SIP"]["SIPLOGIN"].element {
            
            completion(dataDic.attributes, CRMCallHelpers.TypeData.SIP)
            
            return
        }
        
        if let dataDic = xmlDocument["XML"]["SIP"]["CALLSTATUS"].element {
            
            completion(dataDic.attributes, CRMCallHelpers.TypeData.RingIng)
            return
        }

        if let dataDic = xmlDocument["XML"]["USER"]["USERINFO"].element {
            
            let staffList = List<Staff>()
            let productList = List<Product>()
            if let dataStaffDict = xmlDocument["XML"]["USER"]["USERINFO"]["STAFF"].element {
                
                println("Data customer staff: \(dataStaffDict.attributes)")
                let staff = Staff()
                staff.cn = dataStaffDict.attributes["STAFF_CN"]!
                staff.name = dataStaffDict.attributes["STAFF_NAME"]!
                staff.no = dataStaffDict.attributes["STAFF_NO"]!
                staffList.append(staff)
            }
            
            if let dataProductDict = xmlDocument["XML"]["USER"]["USERINFO"]["PRODUCT"].element {
                
                println("Data customer product: \(dataProductDict.attributes)")
                let product = Product()
                product.cn = dataProductDict.attributes["PRODUCT_CN"]!
                product.name = dataProductDict.attributes["PRODUCT_NAME"]!
                product.code = dataProductDict.attributes["PRODUCT_CODE"]!
                productList.append(product)
            }
            
            Cache.shareInstance.customerInfo(with: dataDic.attributes, staffList: staffList, productList: productList)
            
            completion(dataDic.attributes, CRMCallHelpers.TypeData.UserInfo)
        }
        
        completion([:], CRMCallHelpers.TypeData.None)
    }
}

// MARK: USER
struct User: XMLIndexerDeserializable {
    let baseURL: String?
    let cacheProduct: Int?
    let cachePurpose: String?
    let companyPhone: String?
    let email: String?
    let nickName: String?
    let id: String?
    let localPhone: String?
    let mobilePhone: String?
    let telephone: String?
    let sex: String?
    let userKey: String?
    let userName: String?
    let result: String?
    
    static func deserialize(note: XMLIndexer) throws -> User {
        return try User(
            baseURL: note["BASEURL"].value(),
            cacheProduct: note["CACHE_PRODUCT"].value(),
            cachePurpose: note["CACHE_PURPOSE"].value(),
            companyPhone: note["COMPANYPHONE"].value(),
            email: note["EMAIL"].value(),
            nickName: note["NICKNAME"].value(),
            id: note["ID"].value(),
            localPhone: note["LOCALPHONE"].value(),
            mobilePhone: note["MOBILEPHONE"].value(),
            telephone: note["TELEPHONE"].value(),
            sex: note["SEX"].value(),
            userKey: note["USERKEY"].value(),
            userName: note["USERNAME"].value(),
            result: note["RESULT"].value()
        )
    }
}