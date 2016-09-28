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
    static let SIPLoginResultKey = "SIPLoginResult"
    
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
        
        static let RingIng = "CRMCallConfig.Notification.RingIng"
    }
    
    // MARK: API
    struct API {
        
        static func login(with domain: String) -> String {
            return "https://\(domain)/ngw/sign/sso"
        }
        
        static let GetPortAndHostURL = "http://\(CRMCallConfig.HostName)/winapp/hcsong/crmcall/\(CRMCallConfig.HostName)/server.xml"
    }
    
}
