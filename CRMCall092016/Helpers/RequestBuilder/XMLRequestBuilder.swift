//
//  XMLRequestBuilder.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class XMLRequestBuilder {
    
    // MARK: - LOGIN/LOGOUT SOCKET
    static func loginRequest(with userID: String, pass: String, phone: String,domain: String) -> String {
        
        return "<XML> <VER>\(CRMCallConfig.Version)</VER> <USER> <LOGIN ID=\"\(userID)\" PASSWORD=\"\(pass)\" DOMAIN=\"\(domain)\" VER=\"1.0\" ISPTYPE=\"\(CRMCallConfig.IsPType)\" PHONE=\"\(phone)\" DEVICE=\"\(CRMCallConfig.DeviceID)\"></LOGIN> </USER> </XML>"
        
    }
    
    static func logOutRequest() -> String {
        
        return "<XML><VER>\(CRMCallConfig.Version)</VER><USER><LOGOUT></LOGOUT></USER></XML>"
    }
    
    static func liveRequest() -> String {
        return "<XML><VER>\(CRMCallConfig.Version)</VER><ALARM><LIVE/></ALARM></XML>"
    }
    
    // MARK: - USERINFO
    static func getUserInfoRequest(with callID: String, phoneNumber: String, status: String) -> String {
        return "<XML><VER>\(CRMCallConfig.Version)</VER><USER><USERINFO ID=\"\(callID)\" PHONE=\"\(phoneNumber)\" STATUS=\"\(status)\"/></USER></XML>"
    }
    
    // MARK: - CALLERINFOR
    
    static func callerInfoRequest(with ID: String, phone: String, status: String) -> String {
        return "<XML><VER>\(CRMCallConfig.Version)</VER><USER><CALLERINFO ID=\"\(ID)\" PHONE=\"\(phone)\" STATUS=\"\(status)\"/></USER></XML>"
    }
    
    static func statusRequest(with ID: String, broadcast: String, customer: String, mode: String) -> String {
        return "<XML> <VER>\(CRMCallConfig.Version)</VER> <USER> <STATUS ID=\"\(ID)\" BROADCAST=\"\(broadcast)\" CUSTOMER=\"\(customer)\" MODE=\"\(mode)\"/></USER></XML>"
    }
    
    // MARK: - Status
    static func statusRequest(with mode: String) -> String {
        return "<XML> <VER>\(CRMCallConfig.Version)</VER> <USER> <STATUS ID=\"\" BROADCAST=\"\" CUSTOMER=\"\" MODE=\"\(mode)\"/></USER></XML>"
    }
    
    // MARK: - Statuses
    static func statusesRequest() -> String {
        return "<XML><VER>\(CRMCallConfig.Version)</VER><USER><STATUSES/></USER></XML>"
    }


}