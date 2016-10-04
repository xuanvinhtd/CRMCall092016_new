//
//  RequestBuilder.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/26/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class RequestBuilder {
    
    static func login(userId: String, password: String) -> [String: String]{
        return ["gw_id":userId, "gw_pass":password, "method":"crmcall"]
    }
    
    static func cookies() -> [String: String] {
        return ["HANBIRO_GW": CRMCallManager.shareInstance.session_gw, "hmail_key":CRMCallManager.shareInstance.session_key]
    }
}