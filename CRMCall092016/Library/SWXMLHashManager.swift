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
        
        var result: [String: String] = [:]
        
        guard let completion = completion else {
            
            println("Do not found closure COMPLETION")
            return
        }
        
        let xmlDocument = SWXMLHash.parse(xmlData)
        
        if let _ = xmlDocument["XML"]["USER"].element {
            
            result =  userData(withData: xmlDocument)
            completion(result, CRMCallHelpers.TypeData.UserLogin)
            
            return
        }
        
        if let _ = xmlDocument["XML"]["SERVERINFO"].element {
            
            result = getHostAndPost(withData: xmlDocument)
            completion(result, CRMCallHelpers.TypeData.ServerInfo)
            
            return
        }
        
        if let _ = xmlDocument["XML"]["LIVE"].element {
            
            result = getLiveData(withData: xmlDocument)
            completion(result, CRMCallHelpers.TypeData.UserLive)
            
            return
        }
        
        completion(result, CRMCallHelpers.TypeData.None)
    }
    
    private static func userData(withData data: XMLIndexer) -> [String: String] {
        
        if let _ = data["XML"]["USER"]["LOGIN"].element {
            
            guard let userDictionnary = data["XML"]["USER"].element else {
                println("Cannot parse XML: USER LOGIN")
                return [:]
            }
            
            println("Result parse User: --------XXX------- \n \(userDictionnary)")
            
            NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.LoginSuccess, object: nil, userInfo: nil)
            
            return userDictionnary.attributes
        }
        
        if let _ = data["XML"]["USER"]["LOGOUT"].element {

            guard let userDictionnary = data["XML"]["USER"].element else {
                println("Cannot parse XML: USER LOGIN")
                return [:]
            }

            println("Result parse Logout user: --------XXX------- \n \(userDictionnary)")
            
            NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.LogoutSuccess, object: nil, userInfo: nil)
            
            return userDictionnary.attributes
        }
        
        return [:]
    }

    private static func getHostAndPost(withData data: XMLIndexer) -> [String: String] {

        guard let userDictionnary = data["XML"]["SERVERINFO"].element else {
            println("Cannot parse XML: SERVERINFO")
            return [:]
        }
        
        println("Result parse SERVERINFO: --------XXX------- \n \(userDictionnary)")
        
        return userDictionnary.attributes
    }
    
    private static func getLiveData(withData data: XMLIndexer) -> [String: String] {
        
        guard let userDictionnary = data["XML"]["ALARM"].element else {
            println("Cannot parse XML: LIVE")
            return [:]
        }
        
        println("Result parse Live: --------XXX------- \n \(userDictionnary)")
        
        return userDictionnary.attributes
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