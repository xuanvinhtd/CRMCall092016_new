//
//  SettingViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/21/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

    // MARK: - Properties
    
    @IBOutlet weak var hostTextField: NSTextField!
    @IBOutlet weak var idTextField: NSTextField!
    @IBOutlet weak var passworldTextField: NSSecureTextFieldCell!
    @IBOutlet weak var phoneNumberTextField: NSTextFieldCell!
    
    private var handlerNotificationSocketDisConnected: AnyObject?
    private var handlerNotificationSocketDidConnected: AnyObject?
    private var handlerNotificationSIPLoginSuccess: AnyObject?
    private var handlerNotificationSIPLoginFaile: AnyObject?
    private var handlerNotificationRevicedServerInfor: AnyObject?
    
    @IBOutlet weak var progressTestting: NSProgressIndicator!
    
    @IBOutlet weak var testButton: NSButton!
    
    var isTestAgian = true
    var liveTimer: NSTimer?
    
    // MARK: - Initialzation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotification()
        
        if self.liveTimer == nil {
            self.liveTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(SettingViewController.countdown), userInfo: nil, repeats: true)
            
            self.liveTimer?.fire()
        }
    }
    
    deinit {
        deRegisterNotification()
    }
    
    func countdown() {
        isTestAgian = true
    }
    
    // MARK: - Notification

    struct Notification {
        static let SIPLoginSuccess = "SIPLoginSuccessNotification"
        static let SIPLoginFaile = "SIPLoginFaileNotification"
    }

    private func registerNotification() {
        
        handlerNotificationSocketDisConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDisConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.requestLogout()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.testButton.enabled = true
                self.progressTestting.hidden = true
                self.progressTestting.stopAnimation(self)
            })
        })
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.requestLogin(withUserID: self.idTextField.stringValue, passwold: self.passworldTextField.stringValue, phone: self.phoneNumberTextField.stringValue, domain: self.hostTextField.stringValue)
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
        })
        
        handlerNotificationSIPLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPLoginSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Test success", messageText: "Test sucess......", dismissText: "Cancel", completion: nil)
            println("// SHOW MESSAGE TEST ---------------------------------->")
            
            CRMCallManager.shareInstance.deinitSocket()
        })
        
        handlerNotificationSIPLoginFaile = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LoginFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            CRMCallAlert.showNSAlert(with: NSAlertStyle.WarningAlertStyle, title: "Test fail", messageText: "Test fail......", dismissText: "Cancel", completion: nil)
            
            println("// SHOW MESSGAE ERROR TESST ---------------------------->")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.testButton.enabled = true
                self.progressTestting.hidden = true
                self.progressTestting.stopAnimation(self)
            })
        })
        
        handlerNotificationRevicedServerInfor = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.RecivedServerInfor, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.connect()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
        })
    }
    
    private func deRegisterNotification() {
        
        if let notification = handlerNotificationSocketDisConnected {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        
        if let notification = handlerNotificationSocketDidConnected {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationSIPLoginSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationSIPLoginFaile {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationRevicedServerInfor {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
    }

    
    // MARK: - Handling event
    @IBAction func testConnectServer(sender: AnyObject) {
        
        if !isTestAgian {
            CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please wating over a minute..test agian!", dismissText: "Cancel", completion: nil)
            return
        }
        
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            
            if crmCallSocket.isConnectedToHost == true {
                crmCallSocket.requestLogin(withUserID: idTextField.stringValue, passwold: passworldTextField.stringValue, phone: phoneNumberTextField.stringValue, domain: hostTextField.stringValue)
                
            } else {
                println("Connect to server again.....")
                crmCallSocket.connect()
            }
        } else {
            CRMCallManager.shareInstance.initSocket()
        }
        self.testButton.enabled = false
        self.progressTestting.hidden = false
        self.progressTestting.startAnimation(self)
        
        self.isTestAgian = false
    }
}
