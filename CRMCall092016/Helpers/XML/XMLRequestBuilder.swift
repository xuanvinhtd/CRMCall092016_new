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
        
        return  String(format: "<XML> <VER>%@</VER> <USER> <LOGIN ID=\"%@\" PASSWORD=\"%@\" DOMAIN=\"%@\" VER=\"1.0\" ISPTYPE=\"\" PHONE=\"\" DEVICE=\"%@\"></LOGIN> </USER> </XML>", CRMCallConfig.Version, userID, pass, domain, CRMCallConfig.DeviceID)
        
    }
    
    static func logOutRequest() -> String {
        
        return String(format: "<XML><VER>%@</VER><USER><LOGOUT></LOGOUT></USER></XML>", CRMCallConfig.Version)
    }
    
    static func liveRequest() -> String {
        return String(format: "<XML><VER>%@</VER><ALARM><LIVE/></ALARM></XML>", CRMCallConfig.Version)
    }
}