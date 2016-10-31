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
    private var handlerNotificationSocketLoginSuccess: AnyObject!
    private var handlerNotificationSIPLoginSuccess: AnyObject!
    private var handlerNotificationSIPLoginFaile: AnyObject!
    private var handlerNotificationSIPHostFaile: AnyObject!
    private var handlerNotificationRevicedServerInfor: AnyObject!
    
    @IBOutlet weak var progressTestting: NSProgressIndicator!
    
    @IBOutlet weak var testButton: NSButton!
    @IBOutlet weak var signButton: NSButton!
    
    private var isTestAgian = true
    private var liveTimer: NSTimer?
    private var isLoginEnable = false
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("SettingViewControllerID") as! SettingViewController
    }
    
    func initData() {
        
        CRMCallManager.shareInstance.isShowSettingPage = true
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let start = defaults.objectForKey(CRMCallConfig.UserDefaultKey.StartFirstApp) as? String {
            if start == "0" || start == "" {
                return
            }
        } else {
            return
        }
        
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
//            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Will Logout and close main or login windows", dismissText: "Cancel", completion: { result in
            
                CRMCallManager.shareInstance.deinitSocket()
                CRMCallManager.shareInstance.isUserLoginSuccess = false
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(0, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
                
                CRMCallManager.shareInstance.isShowMainPage = false
                NSNotificationCenter.defaultCenter().postNotificationName(MainViewController.Notification.ShowPageSigin, object: nil, userInfo: nil)
                
                CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.LoginWindowController)
            //})
        }
    }
    
    override func viewDidDisappear() {
        
        saveSettingInfo()

        deregisterNotification()
        liveTimer = nil
        CRMCallManager.shareInstance.isShowSettingPage = false
        
        CRMCallManager.shareInstance.deinitSocket()
        
        CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController)
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
                self.showAndStartProgress(false)
                
                self.signButton.enabled = self.isLoginEnable
            })
            
            if NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult) != "1" {
                if let  w = self.view.window {
                     CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Test fail, please review phone number!!", dismissText: "Ok", completion: { result in })
                }
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
            
            self.saveSettingInfo()
            if let  w = self.view.window {
                CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Test success, can receive and call.", dismissText: "Ok", completion: { result in })
            }
            
            self.isLoginEnable = true
            CRMCallManager.shareInstance.deinitSocket()
        })
        
        handlerNotificationSIPLoginFaile = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPLoginFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let w = self.view.window {
                CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Test fail, please review id and password!!", dismissText: "Ok", completion: { result in })
            }
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                CRMCallManager.shareInstance.deinitSocket()
                crmCallSocket.logoutRequest()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.showAndStartProgress(false)
            })
            
            self.isLoginEnable = false
            self.isTestAgian = true
        })
        
        handlerNotificationSIPHostFaile = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPHostFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let w = self.view.window {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Test fail, please review host name!!", dismissText: "Ok", completion: { result in })
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.showAndStartProgress(false)
            })
            
            self.isLoginEnable = false
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
        
        handlerNotificationSocketLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.LoginSuccessSocket, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            CRMCallManager.shareInstance.isSocketLoginSuccess = true
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(0, forKey: CRMCallConfig.UserDefaultKey.SaveID)
            defaults.setObject(0, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
            defaults.setObject("0", forKey: CRMCallConfig.UserDefaultKey.SIPLoginResult)
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketLoginSuccess)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDisConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDidConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPLoginSuccess)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPLoginFaile)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRevicedServerInfor)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPHostFaile)
    }
    
    // MARK: - Handling event
    
    @IBAction func actionShowSignIn(sender: AnyObject) {
        CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.LoginWindowController)
    }
    
    
    @IBAction func testConnectServer(sender: AnyObject) {
        
        if !CRMCallManager.shareInstance.isInternetConnect {
            showMessageNotConnectInternet()
            return
        }
        
        if (CRMCallManager.shareInstance.isShowLoginPage || CRMCallManager.shareInstance.isShowMainPage) || CRMCallManager.shareInstance.isUserLoginSuccess {
            if let w = self.view.window {
                CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please Logout and close login windows", dismissText: "Ok", completion: { result in })
            }
            return
        }

        if !isTestAgian {
            if let w = self.view.window {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please wait a minute then check agian!", dismissText: "Ok", completion: { result in })
            }
            return
        }
        
        showAndStartProgress(true)
        
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            
            // Get port and host
            crmCallSocket.getIdAndHost(withHostName: self.hostTextField.stringValue, Result: { (result) in
                if !result {
                    self.showMessageNotConnectInternet()
                }
            })
            
        } else {
            CRMCallManager.shareInstance.initSocket()
           
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.getIdAndHost(withHostName: self.hostTextField.stringValue, Result: { (result) in
                    if !result {
                        self.showMessageNotConnectInternet()
                    }
                })
            }
        }
        
        self.isTestAgian = false
    }
    
    
    
    private func showMessageNotConnectInternet() {
        
        showAndStartProgress(false)
        if let w = self.view.window {
        CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please check connect internet", dismissText: "Ok", completion: { result in })
        }
    }
    
    private func showAndStartProgress(state: Bool) {
        if state {
            self.enableControl(state)
            self.progressTestting.startAnimation(self)
        } else {
            self.enableControl(state)
            self.progressTestting.stopAnimation(self)
        }
    }
    
    private func checkSipLogin() -> Bool {
        if let sip = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult) as? String {
            if sip == "0" || sip == "" {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    private func enableControl(state: Bool) {
        _ = self.hostTextField.stringValue
        _ = self.idTextField.stringValue
        _ = self.phoneNumberTextField.stringValue
        _ = self.passworldTextField.stringValue
        
        self.testButton.enabled = !state
        self.hostTextField.enabled = !state
        self.idTextField.enabled = !state
        self.phoneNumberTextField.enabled = !state
        self.passworldTextField.enabled = !state
        self.progressTestting.hidden = !state
        self.signButton.enabled = !state
    }
    
    private func saveSettingInfo() {
        // SAVE Info Setting
        let keyChain = Keychain(service: CRMCallConfig.KeyChainKey.ServiceName)
        
        keyChain[CRMCallConfig.KeyChainKey.PhoneNumberSetting] = phoneNumberTextField.stringValue
        keyChain[CRMCallConfig.KeyChainKey.HostSetting] = hostTextField.stringValue
        keyChain[CRMCallConfig.KeyChainKey.IDSetting] =  idTextField.stringValue
        keyChain[CRMCallConfig.KeyChainKey.PasswordSetting] = passworldTextField.stringValue
    }
}
