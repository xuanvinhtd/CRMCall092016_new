//
//  CRMCallManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/21/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class CRMCallManager {
    // MARK: Properties
    static let shareInstance = CRMCallManager()
    
    var crmCallSocket: CRMCallSocket?
    
    var myCurrentStatus: CRMCallHelpers.UserStatus = CRMCallHelpers.UserStatus.None
    
    var session_gw = ""
    var session_key = ""
    var isLoginSuccess = false
    
    // MARK: Initialzation
    
    init () {
        self.crmCallSocket = CRMCallSocket()
    }
    
    func initSocket() {
        if let _ = self.crmCallSocket {
        } else {
            self.crmCallSocket = CRMCallSocket()
        }
    }
    
    func deinitSocket() {
        if let _ = self.crmCallSocket {
            crmCallSocket!.stopLiveTimer()
            crmCallSocket!.disConnect()
            crmCallSocket!.deInit()
            crmCallSocket = nil
        }
    }
    
}
