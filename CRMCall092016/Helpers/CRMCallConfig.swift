//
//  CRMCallConfig.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class CRMCallConfig {
    
    static let Version = "20150202"
    static let DeviceID = "MAC"
    static let IsPType = "4"
    
    static let AppGroupID = "com.xuanvintd.CRMCall092016"
    
    static let HostName = "global3.hanbiro.com"
    
    static let TimerInterval = 10.0
    
    static let HeaderLength:UInt = 6
    
    static let UUIDKey = "UUID"
    
    // MARK: - UserDefault key
    struct UserDefaultKey {
        static let SIPLoginResult = "SIPLoginResult"
        
        static let AutoLogin = "CRMCallAutoLogin"
        static let SaveID = "CRMCallSaveID"
        
        static let HostSetting = "HostSetting"
        static let IDSetting = "IDSetting"
        static let PasswordSetting = "PasswordSetting"
        static let PhoneNumberSetting = "PhoneNumberSetting"
        
        static let Domain = "Domain"
        static let UserID = "UserID"
        static let PasswordUser = "PasswordUser"
    }
    
    // MARK: Tab
    struct Tab {
        static let Default = 0
        static let Header = 1
        static let BodyData = 2
    }
    
    // MARK: Notification
    struct Notification {
        static let SocketDidConnected = "CRMCallConfig.Notification.SocketDidConnected"
        static let SocketDisConnected = "CRMCallConfig.Notification.SocketDisConnected"
        static let RecivedServerInfor = "CRMCallConfig.Notification.RecivedServerInfor"
        static let LoginSuccessSocket = "CRMCallConfig.Notification.LoginSuccessSocket"
        static let LoginFailSocket    = "CRMCallConfig.Notification.LoginFailSocket"
        
        static let LiveServer = "CRMCallConfig.Notification.LiveServer"
        
        static let RingIng = "CRMCallConfig.Notification.RingIng"
        static let InviteEvent = "CRMCallConfig.Notification.InviteEvent"
        static let InviteResultEvent = "CRMCallConfig.Notification.InviteResultEvent"
        static let CancelEvent = "CRMCallConfig.Notification.CancelEvent"
        static let BusyEvent = "CRMCallConfig.Notification.BusyEvent"
        static let ByeEvent = "CRMCallConfig.Notification.ByeEvent"
    }
    
    // MARK: API
    struct API {
        
        static func login(with domain: String) -> String {
            return "https://\(domain)/ngw/sign/sso"
        }
        
        static func phoneType() -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/get_cti_contact_label"
        }
        
        static func purposeList(withCNKey cnKey: String, lang: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customization/options/options_by_category_langcode/\(cnKey)/activity_purposes/\(lang)"
        }
        
        static func productList(withCNKey cnKey: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/product/management/list_prod/\(cnKey)"
        }
        
        static let GetPortAndHostURL = "http://\(CRMCallConfig.HostName)/winapp/hcsong/crmcall/\(CRMCallConfig.HostName)/server.xml"
    }
    
}
