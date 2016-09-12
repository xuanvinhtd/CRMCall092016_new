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
    static let HostName = "global3.hanbiro.com"
    
    static let HeaderLength:UInt = 6
    
    // MARK: Tab
    struct Tab {
        static let Default = 0
        static let Header = 1
        static let BodyData = 2
    }
    
    // MARK: Notification
    struct Notification {
        static let SocketDidConnected = "SocketManager.SocketDidConnected"
        static let SocketDisConnected = "SocketManager.SocketDisConnected"
    }
    
    // MARK: API
    struct API {
        static let GetPortAndHostURL = "http://\(CRMCallConfig.HostName)/winapp/hcsong/crmcall/\(CRMCallConfig.HostName)/server.xml"
    }
    
    
    
    
}
