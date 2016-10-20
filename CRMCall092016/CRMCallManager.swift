//
//  CRMCallManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/21/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

final class CRMCallManager {
    // MARK: Properties
    static let shareInstance = CRMCallManager()
    
    var screenManager: [String: NSWindowController] = [:]
    
    var crmCallSocket: CRMCallSocket?
    
    var myCurrentStatus: CRMCallHelpers.UserStatus = CRMCallHelpers.UserStatus.None
    var myCurrentDirection: CRMCallHelpers.Direction = CRMCallHelpers.Direction.None
    
    var session_gw = ""
    var session_key = ""
    var cn = ""
    
    var isUserLoginSuccess = false
    var isSocketLoginSuccess = false
    
    var isShowLoginPage = false
    var isShowMainPage = false
    
    var domain = ""
    
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
        
        session_gw = ""
        session_key = ""
        isUserLoginSuccess = false
        isSocketLoginSuccess = false
    }
    
    // MARK: - Manager Screen
    
    func showWindow(withNameScreen name: String) {
        dispatch_async(dispatch_get_main_queue(), {
            if let windowController = CRMCallManager.shareInstance.screenManager[name] {
                windowController.showWindow(nil)
            } else {
                var windowController = NSWindowController()
                
                switch name {
                    
                case CRMCallHelpers.NameScreen.CustomerListViewController:
                        windowController = CustomerListWindowController.createInstance()
                    break
                    
                case CRMCallHelpers.NameScreen.HistoryCallWindowController:
                    windowController = HistoryCallWindowController.createInstance()
                    break
                    
                case CRMCallHelpers.NameScreen.LoginWindowController:
                    windowController = LoginWindowController.createInstance()
                    break
                    
                case CRMCallHelpers.NameScreen.RingIngWindowController:
                    windowController = RingIngWindowController.createInstance()
                    break
                    
                case CRMCallHelpers.NameScreen.StaffAvailabilityWindowController:
                    windowController = StaffAvailabilityWindowController.createInstance()
                    break
                default:
                    break
                }
                
                windowController.showWindow(nil)
                CRMCallManager.shareInstance.screenManager[name] = windowController
            }
            
        })
    }
    
    func closeWindow(withNameScreen name: String) {
        dispatch_async(dispatch_get_main_queue()) {
            if let windowController = CRMCallManager.shareInstance.screenManager[name] {
                windowController.close()
                CRMCallManager.shareInstance.screenManager.removeValueForKey(name)
            }
        }
    }
    
}
