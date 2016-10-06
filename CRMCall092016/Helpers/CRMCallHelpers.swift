//
//  CRMCallHelpers.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/14/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

final class CRMCallHelpers {
    
    static let storyBoard = NSStoryboard.init(name: "Main", bundle: nil)
    static let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    enum TypeData {
        case UserLogin
        case UserLogout
        case UserInfo
        case ServerInfo
        case UserLive
        case SIP
        case RingIng
        case None
    }
    
    enum UserStatus: String {
        case None = "0"
        case Ringing = "1"
        case Busy = "2"
    }
    
    enum Direction: String {
        case None = "NONE"
        case InBound = "INBOUND"
        case OutBound = "OUTBOUND"
    }
    
    enum Event: String {
        case Invite = "INVITE"
        case Cancel = "CANCEL"
        case Busy = "BUSY"
        case InviteResult = "INVITE_RESULT"
        case Bye = "BYE"
    }
    
    struct NameScreen {
        static let LoginWindowController = "LoginWindowController"
        static let HistoryCallWindowController = "HistoryCallWindowController"
        static let RingIngWindowController = "RingIngWindowController"
    }
    
    static func getUUID() -> String {
        if let uuid = NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UUIDKey) {
            return uuid
        } else {
            let uuidObject = CFUUIDCreate(kCFAllocatorDefault)
            let uuid = CFUUIDCreateString(kCFAllocatorDefault, uuidObject)
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: CRMCallConfig.UUIDKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            return uuid as String
        }
    }
    
    static func reconnectToSocket() {
        //GET SETTING INFO
        let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
        let hostSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.HostSetting) as? String
        let idSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.IDSetting) as? String
        let pwdSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PasswordSetting) as? String
        
        guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
            println("Not found info setting")
            return
        }
        
        if CRMCallManager.shareInstance.isSocketLoginSuccess == false {
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {  // SIPLOGIN
                
                if crmCallSocket.isConnectedToHost == true {
                    crmCallSocket.loginRequest(withUserID: id, passwold: pwd, phone: phone, domain: host)
                    
                } else {
                    println("Connect to server again.....")
                    crmCallSocket.connect()
                }
            } else {
                CRMCallManager.shareInstance.initSocket()
            }
        }
    }
    
    static func findKeyForValue(value: String, dictionary: [String: String]) ->String?
    {
        for (key, strValue) in dictionary {
            if (value == strValue) {
                return key
            }
        }
        
        return nil
    }
    
    static func getDateNow(withFormat format: String) -> String {
    
        return ""
    }
}