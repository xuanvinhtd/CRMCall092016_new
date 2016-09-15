//
//  XMLRequestBuilder.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class XMLRequestBuilder {
    
    // MARK: - LOGIN/LOGOUT
    static func loginRequest(with userID: String, pass: String, domain: String) -> String {
        
        return "<XML> <VER>\(CRMCallConfig.Version)</VER> <USER> <LOGIN ID=\"\(userID)\" PASSWORD=\"\(pass)\" DOMAIN=\"\(domain)\" VER=\"1.0\" ISPTYPE=\"\" PHONE=\"\" DEVICE=\"\(CRMCallConfig.DeviceID)\"></LOGIN> </USER> </XML>"
        
    }
    
    static func logOutRequest() -> String {
        
        return "<XML><VER>\(CRMCallConfig.Version)</VER><USER><LOGOUT></LOGOUT></USER></XML>"
    }
    
    static func liveRequest() -> String {
        return "<XML><VER>\(CRMCallConfig.Version)</VER><ALARM><LIVE/></ALARM></XML>"
    }
}