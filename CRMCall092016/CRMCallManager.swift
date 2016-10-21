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
    var port: UInt16 = 0
    var host: String = ""
    
    var myCurrentStatus: CRMCallHelpers.UserStatus = CRMCallHelpers.UserStatus.None
    var myCurrentDirection: CRMCallHelpers.Direction = CRMCallHelpers.Direction.None
    
    var session_gw = ""
    var session_key = ""
    var cn = ""
    
    var isUserLoginSuccess = false
    var isSocketLoginSuccess = false
    
    var isShowLoginPage = false
    var isShowMainPage = false
    
    var isInternetConnect = true
    
    var domain = ""
    
    private var handlerNotificationReConnetSocket: AnyObject!
    private var handlerNotificationSocketDidConnected: AnyObject!
    private var handlerNotificationNotConnectInternet: AnyObject!
    
    // MARK: Initialzation
    
    init () {
        self.crmCallSocket = CRMCallSocket()
        self.registerNotification()
    }
    
    func initSocket() {
        if let _ = self.crmCallSocket {
        } else {
            self.crmCallSocket = CRMCallSocket()
        }
    }
    
    deinit {
        deRegisterNotification()
        deinitSocket()
    }
    
    func deinitSocket() {
        if let _ = self.crmCallSocket {
            crmCallSocket!.stopLiveTimer()
            crmCallSocket!.disConnect()
            crmCallSocket!.deInit()
            crmCallSocket = nil
        }
        
        isUserLoginSuccess = false
        isSocketLoginSuccess = false
    }
    
    // MARK: - Notification
    func registerNotification() {
        handlerNotificationReConnetSocket = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.ReConnectSocket, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallManager.shareInstance.deinitSocket()
            
            println("----------------xxxx---RECONNET SOCKET TO SERVER---xxxx------------")
            CRMCallHelpers.reconnectToSocket()
            
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket  {
                if CRMCallManager.shareInstance.host != "" && CRMCallManager.shareInstance.port != 0 {
                    crmCallSocket.connect(withPort: CRMCallManager.shareInstance.port, host: CRMCallManager.shareInstance.host)
                }
            }
        })
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if CRMCallManager.shareInstance.isShowMainPage {
                CRMCallHelpers.reconnectToSocket()
            }
        })
        
        handlerNotificationNotConnectInternet = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.NotConnetInternet, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if !CRMCallManager.shareInstance.isInternetConnect {
                CRMCallAlert.showNSAlert(with: NSAlertStyle.WarningAlertStyle, title: "Notification", messageText: "Please check connect internet", dismissText: "Cancel", completion: { (data) in })
            }
        })
    }
    
    func deRegisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationReConnetSocket)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDidConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationNotConnectInternet)
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
