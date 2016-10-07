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
    
    static func saveDailyCall(withCN cn: String, groupCall: String, regdate: String, dateTime: String,
                                     priority: Int, duration: Int, direction: String, note: String,
                                     subject: String,
                                     customerDict: [[String: AnyObject]], staffDict: [[String: AnyObject]], purposeDict: [[String: AnyObject]]) -> [String: AnyObject]{
        return ["cn":cn, "group_call": groupCall, "regdate":regdate, "date_time":dateTime,
                "category": "", "priority":priority, "duration": duration, "direction": direction,
                "content": note, "subject":subject,
                "customer":customerDict, "staff": staffDict, "purpose": purposeDict,
                "HANBIRO_GW": CRMCallManager.shareInstance.session_gw,
                "hmail_key":CRMCallManager.shareInstance.session_key]
    }
    
    static func registerEmployee(withName name: String, info: [[String: AnyObject]]) -> [String: AnyObject] {
        return ["name": name, "phone_data": info]
    }

}