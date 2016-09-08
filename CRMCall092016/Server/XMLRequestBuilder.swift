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
    class func createLoginRequest(with userID: String, pass: String, domain: String) -> String {
        
        let xml = String(format: "<XML> <VER>%@</VER> <USER> <LOGIN ID=\"%@\" PASSWORD=\"%@\" DOMAIN=\"%@\" VER=\"1.0\" ISPTYPE=\"\" PHONE=\"\" DEVICE=\"%@\"></LOGIN> </USER> </XML>", CRMCallConfig.Version, userID, pass, domain, CRMCallConfig.DeviceID)
        
        return xml
    }
}