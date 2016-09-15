//
//  SWXMLHashManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/8/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

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
        
        if let dataDic = xmlDocument["XML"]["ALARM"].element {
            
            completion(dataDic.attributes, CRMCallHelpers.TypeData.UserLive)
            
            return
        }
        
        completion([:], CRMCallHelpers.TypeData.None)
    }
    
//    private static func userData(withData data: XMLIndexer) -> [String: String] {
//        
//        if let userDic = data["XML"]["USER"]["LOGIN"].element {
//            
//            NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.LoginSuccess, object: nil, userInfo: nil)
//            
//            return userDic.attributes
//        }
//        
//        if let userDic = data["XML"]["USER"]["LOGOUT"].element {
//            
//            NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.LogoutSuccess, object: nil, userInfo: nil)
//            
//            return userDic.attributes
//        }
//        
//        return [:]
//    }

//    private static func getHostAndPost(withData data: XMLIndexer) -> [String: String] {
//
//        guard let userDic = data["XML"]["SERVERINFO"].element else {
//            println("Cannot parse XML: SERVERINFO")
//            return [:]
//        }
//
//        return userDic.attributes
//    }
//    
//    private static func getLiveData(withData data: XMLIndexer) -> [String: String] {
//        
//        guard let userDic = data["XML"]["ALARM"].element else {
//            println("Cannot parse XML: LIVE")
//            return [:]
//        }
//                
//        return userDic.attributes
//    }
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