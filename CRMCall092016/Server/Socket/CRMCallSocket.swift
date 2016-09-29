//
//  CRMCallSocket.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/12/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Chronos

final class CRMCallSocket: BaseSocket {
    
    // MARK: - Properties
    var timer: DispatchTimer?
    
    var handerNotificationLoginSuccess: AnyObject?
    
    // MARK: - Initialzation
    override init() {
        
        super.init()
        
        self.timer = DispatchTimer(interval: 10.0, closure: {
            (timer: RepeatingTimer, count: Int) in
            self.liveRequest()
        })

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
            handerNotificationLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.LiveServer, object: nil, queue: nil, usingBlock: { notification in
                
                println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
                
                self.startLiveTimer(true)
            })
        }
    }
    
    func deregisterNotification() {
        
        if let handerNotificationLoginSuccess = handerNotificationLoginSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(handerNotificationLoginSuccess)
        }
    }
    
    // MARK: - COMUNICATION API
    
    func loginRequest(withUserID userID: String, passwold: String, phone: String, domain: String) {
        println("SEND REQUEST LOGIN")
        let xmlLogin = XMLRequestBuilder.loginRequest(with: userID, pass: passwold, phone: phone, domain: domain)
        
        configAndSendData(withData: xmlLogin)
    }
    
    func logoutRequest() {
        println("SEND REQUEST LOGOUT")
        let xmlLogOut = XMLRequestBuilder.logOutRequest()
        
        configAndSendData(withData: xmlLogOut)
    }
    
    // MARK: - LIVE API
    func startLiveTimer(now : Bool) {
        guard let timer = self.timer else {
            println("timer not init")
            return
        }
        timer.start(now)
    }
    
    func stopLiveTimer() {
        guard let timer = self.timer else {
            println("timer not init")
            return
        }
        timer.cancel()
        self.timer = nil
    }
    
    func liveRequest() {
        
        println("PING TO SERVER WITH SCHEDULE \(CRMCallConfig.TimerInterval)s")
        
        let strRequest = XMLRequestBuilder.liveRequest()
        
        configAndSendData(withData: strRequest)
    }
    
    // MARK: - USERINFO
    func getUserInfoRequest(with callID: String, phonenumber: String) {
        
        println("SEND REQUEST GET USER INFO ")
        
        let currentStatus = CRMCallManager.shareInstance.myCurrentStatus.rawValue
        let strRequest = XMLRequestBuilder.getUserInfoRequest(with: callID, phoneNumber: phonenumber, status: currentStatus)
        
        configAndSendData(withData: strRequest)
    }
    
    // MARK: - STATUS
    
    func statusRequest() {
        
        println("SEND REQUEST GET STATUS ")
        
        let currentStatus = CRMCallManager.shareInstance.myCurrentStatus.rawValue
        let strRequest = XMLRequestBuilder.statusRequest(with: currentStatus)
        
        configAndSendData(withData: strRequest)
    }
    
    // MARK: - STATUSES
    
    func statusesRequest() {
        
        println("SEND REQUEST GET STATUSES ")
        
        let strRequest = XMLRequestBuilder.statusesRequest()
        
        configAndSendData(withData: strRequest)
    }


}