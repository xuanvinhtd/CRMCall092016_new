//
//  CRMCallSocket.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/12/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class CRMCallSocket: BaseSocket {
    
    // MARK: - Properties
    var liveTimer: NSTimer?
    
    var handerNotificationLoginSuccess: AnyObject?
    
    // MARK: - Initialzation
    override init() {
        
        super.init()
        
        registerNotification()
    }
    
    deinit {
        deregisterNotification()
    }
    
    func deInit() {
        deregisterNotification()
    }
    // MARK: - NOTIFICATION
    
    private func registerNotification() {
        
        if handerNotificationLoginSuccess == nil {
            handerNotificationLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LoginSuccess, object: nil, queue: nil, usingBlock: { notification in
                
                println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
                
                self.startLiveTimer()
            })
        }
    }
    
    func deregisterNotification() {
        
        if let handerNotificationLoginSuccess = handerNotificationLoginSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(handerNotificationLoginSuccess)
        }
    }
    
    // MARK: - COMUNICATION API
    
    func requestLogin(withUserID userID: String, passwold: String, phone: String, domain: String) {
        
        let xmlLogin = XMLRequestBuilder.loginRequest(with: userID, pass: passwold, phone: phone, domain: domain)
        
        configAndSendData(withData: xmlLogin)
    }
    
    func requestLogout() {
        
        let xmlLogOut = XMLRequestBuilder.logOutRequest()
        
        configAndSendData(withData: xmlLogOut)
    }
    
    // MARK: LIVE API
    func startLiveTimer() {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if self.liveTimer == nil {
                self.liveTimer = NSTimer.scheduledTimerWithTimeInterval(CRMCallConfig.TimerInterval, target: self, selector: #selector(CRMCallSocket.requestLive), userInfo: nil, repeats: true)
                
                self.liveTimer?.fire()
            }
        }
    }
    
    func stopLiveTimer() {
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let _liveTimer = self.liveTimer else {
                println("liveTimer not init")
                return
            }
            
            _liveTimer.invalidate()
        }
    }
    
    func requestLive() {
        
        println("PING TO SERVER WITH SCHEDULE \(CRMCallConfig.TimerInterval)s")
        
        let strRequest = XMLRequestBuilder.liveRequest()
        
        configAndSendData(withData: strRequest)
    }
}