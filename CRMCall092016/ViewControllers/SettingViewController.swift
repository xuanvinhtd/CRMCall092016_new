//
//  SettingViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/21/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa
import KeychainAccess

class SettingViewController: NSViewController, ViewControllerProtocol {

    // MARK: - Properties
    
    @IBOutlet weak var hostTextField: NSTextField!
    @IBOutlet weak var idTextField: NSTextField!
    @IBOutlet weak var passworldTextField: NSSecureTextFieldCell!
    @IBOutlet weak var phoneNumberTextField: NSTextFieldCell!
    
    private var handlerNotificationSocketDisConnected: AnyObject!
    private var handlerNotificationSocketDidConnected: AnyObject!
    private var handlerNotificationSIPLoginSuccess: AnyObject!
    private var handlerNotificationSIPLoginFaile: AnyObject!
    private var handlerNotificationSIPHostFaile: AnyObject!
    private var handlerNotificationRevicedServerInfor: AnyObject!
    
    @IBOutlet weak var progressTestting: NSProgressIndicator!
    
    @IBOutlet weak var testButton: NSButton!
    
    private var isTestAgian = true
    private var liveTimer: NSTimer?
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("SettingViewControllerID") as! SettingViewController
    }
    
    func initData() {
        
        // GET SETTING INFO
        let keyChain = Keychain(service: CRMCallConfig.KeyChainKey.ServiceName)
        
        let phoneSetting = keyChain[CRMCallConfig.KeyChainKey.PhoneNumberSetting]
        let hostSetting = keyChain[CRMCallConfig.KeyChainKey.HostSetting]
        let idSetting = keyChain[CRMCallConfig.KeyChainKey.IDSetting]
        let pwdSetting = keyChain[CRMCallConfig.KeyChainKey.PasswordSetting]
        
        guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
            println("Please, call setting and again. \nGo to Preferences...")
            return
        }
        
        hostTextField.stringValue = host
        idTextField.stringValue = id
        passworldTextField.stringValue = pwd
        phoneNumberTextField.stringValue = phone
    }
    
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init Screen SettingViewController")
        
        initData()
        
        registerNotification()
        
        if self.liveTimer == nil {
            self.liveTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(SettingViewController.countdown), userInfo: nil, repeats: true)
            
            self.liveTimer?.fire()
        }
    }
    
    deinit {
        deregisterNotification()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Call Setting"
        
        if CRMCallManager.shareInstance.isShowLoginPage || CRMCallManager.shareInstance.isShowMainPage {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Please Logout and close login windows", dismissText: "Cancel", completion: { result in })
        }
    }
    
    override func viewDidDisappear() {
        
        // SAVE Info Setting
        let keyChain = Keychain(service: CRMCallConfig.KeyChainKey.ServiceName)
        
        keyChain[CRMCallConfig.KeyChainKey.PhoneNumberSetting] = phoneNumberTextField.stringValue
        keyChain[CRMCallConfig.KeyChainKey.HostSetting] = hostTextField.stringValue
        keyChain[CRMCallConfig.KeyChainKey.IDSetting] =  idTextField.stringValue
        keyChain[CRMCallConfig.KeyChainKey.PasswordSetting] = passworldTextField.stringValue

        deregisterNotification()
        self.liveTimer = nil
    }
    
    func countdown() {
        isTestAgian = true
    }
    
    // MARK: - Notification

    struct Notification {
        static let SIPLoginSuccess = "SIPLoginSuccess"
        static let SIPLoginFaile = "SIPLoginFaile"
        static let SIPHostFaile = "SIPHostFaile"
    }

    func registerNotification() {
        
        handlerNotificationSocketDisConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDisConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                CRMCallManager.shareInstance.deinitSocket()
                crmCallSocket.logoutRequest()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.testButton.enabled = true
                self.progressTestting.hidden = true
                self.progressTestting.stopAnimation(self)
            })
            
            if NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult) != "1" {
                CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Test fail, please review phone number!!", dismissText: "Cancel", completion: { result in })
                self.isTestAgian = true
            }
        })
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.loginRequest(withUserID: self.idTextField.stringValue, passwold: self.passworldTextField.stringValue, phone: self.phoneNumberTextField.stringValue, domain: self.hostTextField.stringValue)
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
        })
        
        handlerNotificationSIPLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPLoginSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Test success, can receive and call.", dismissText: "Cancel", completion: { result in })

            CRMCallManager.shareInstance.deinitSocket()
        })
        
        handlerNotificationSIPLoginFaile = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPLoginFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Test fail, please review id and password!!", dismissText: "Cancel", completion: { result in })

            println("// SHOW MESSGAE ERROR TESST ---------------------------->")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.testButton.enabled = true
                self.progressTestting.hidden = true
                self.progressTestting.stopAnimation(self)
            })
            self.isTestAgian = true
        })
        
        handlerNotificationSIPHostFaile = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPHostFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Test fail, please review host name!!", dismissText: "Cancel", completion: { result in })
            
            println("// SHOW MESSGAE ERROR HOST ---------------------------->")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.testButton.enabled = true
                self.progressTestting.hidden = true
                self.progressTestting.stopAnimation(self)
            })
            self.isTestAgian = true
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
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDisConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDidConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPLoginSuccess)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPLoginFaile)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRevicedServerInfor)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPHostFaile)
    }
    
    // MARK: - Handling event
    @IBAction func testConnectServer(sender: AnyObject) {
        
        if CRMCallManager.shareInstance.isShowLoginPage || CRMCallManager.shareInstance.isShowMainPage {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Please Logout and close login windows", dismissText: "Cancel", completion: { result in })
            return
        }

        if !isTestAgian {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Please wait a minute then check agian!", dismissText: "Cancel", completion: { result in })
            return
        }
        
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            
            if crmCallSocket.isConnectedToHost == true {
                crmCallSocket.loginRequest(withUserID: idTextField.stringValue, passwold: passworldTextField.stringValue, phone: phoneNumberTextField.stringValue, domain: hostTextField.stringValue)
                
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
