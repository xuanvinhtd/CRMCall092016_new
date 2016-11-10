//
//  LoginViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/23/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

final class LoginViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    @IBOutlet weak var domainTextField: NSTextField!
    @IBOutlet weak var userIDTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var isSaveIDCheckBox: NSButton!
    @IBOutlet weak var isAutoLoginCheckBox: NSButton!
    @IBOutlet weak var btnLogin: NSButton!
    @IBOutlet weak var progressLogin: NSProgressIndicator!
    
    private var handlerNotificationSocketDisConnected: AnyObject!
    private var handlerNotificationSocketDidConnected: AnyObject!
    private var handlerNotificationSocketLoginSuccess: AnyObject!
    private var handlerNotificationSocketLoginFail: AnyObject!
    private var handlerNotificationSocketLogoutSuccess: AnyObject!
    private var handlerNotificationRevicedServerInfor: AnyObject!
    private var handlerNotificationNotConnectInternet: AnyObject!
    private var handlerNotificationRelogin: AnyObject!
    
    var flatDisconnect = true
    var flatShowSettingPage = true
    var isLoginManual = true
    
    private var flatRegisterNotification = false
    
    // MARK: - Intialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("LoginViewControllerID") as! LoginViewController
    }
    
    func initData() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let domain = KeyChainManager.shareInstance.getValue(withKey: KeyChainManager.Keys.HostSetting)
        
        domainTextField.stringValue = domain ?? ""
        userIDTextField.stringValue = ""
        passwordTextField.stringValue = ""

        CRMCallManager.shareInstance.isShowLoginPage = CRMCallManager.shareInstance.isShowMainPage
        
        if !CRMCallManager.shareInstance.isShowLoginPage {
            deregisterNotification()
        } else  {
            if CRMCallManager.shareInstance.isShowSettingPage {
                CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController)
            }
        }
        
        if let isSaveID = defaults[CRMCallConfig.UserDefaultKey.SaveID] as? Int {
            if isSaveID == 1 {
                let domain = KeyChainManager.shareInstance.getValue(withKey: KeyChainManager.Keys.Domain)
                let userID = KeyChainManager.shareInstance.getValue(withKey: KeyChainManager.Keys.UserID)
                
                self.domainTextField.stringValue = domain ?? ""
                self.userIDTextField.stringValue = userID ?? ""
            }
            isSaveIDCheckBox.state = isSaveID
        } else {
            defaults[CRMCallConfig.UserDefaultKey.SaveID] = isSaveIDCheckBox.state
        }
        
        if let isAutoLogin = defaults[CRMCallConfig.UserDefaultKey.AutoLogin] as? Int {
            if isAutoLogin == 1 {
                
                let domain = KeyChainManager.shareInstance.getValue(withKey: KeyChainManager.Keys.Domain)
                let userID = KeyChainManager.shareInstance.getValue(withKey: KeyChainManager.Keys.UserID)
                let password = KeyChainManager.shareInstance.getValue(withKey: KeyChainManager.Keys.PasswordUser)
                
                self.passwordTextField.stringValue = password ?? ""
                self.domainTextField.stringValue = domain ?? ""
                self.userIDTextField.stringValue = userID ?? ""
                
                isLoginManual = false
                actionLogin("")
            } else {
               isLoginManual = true
            }
            
            isAutoLoginCheckBox.state = isAutoLogin
        } else {
            defaults[CRMCallConfig.UserDefaultKey.AutoLogin] = isAutoLoginCheckBox.state
        }
    }
    
    // MARK: - View life cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init screen LoginViewController")
        CRMCallManager.shareInstance.isShowLoginPage = true
        
        registerNotification()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // CHECK SETTING CALL
        if let startFirst = defaults[CRMCallConfig.UserDefaultKey.StartFirstApp] as? String {
            if startFirst == "0" || startFirst == "" {
                showAndStartProgress(false)
                CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please, setting and test phone number", dismissText: "Ok", completion: { (result) in
                    
                    CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController, value: "")
                })
                
                return
            }
        } else {
            showAndStartProgress(false)
            CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please, setting and test phone number", dismissText: "Ok", completion: { (result) in
                
                CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController, value: "")
            })
            
            return
        }
        
        if let sip = defaults[CRMCallConfig.UserDefaultKey.SIPLoginResult] as? String {
            if sip == "0" || sip == "" {
                showAndStartProgress(false)
                CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please, setting and test phone number", dismissText: "Cancel", completion: { (result) in
                    
                    CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController, value: "")
                })
                
                return
            }
        } else {
            showAndStartProgress(false)
            CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please, setting and test phone number", dismissText: "Cancel", completion: { (result) in
                
                CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController, value: "")
            })
            
            return
        }

        initData()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Login"
        
//        domainTextField.becomeFirstResponder()
//        
//        domainTextField.nextKeyView = userIDTextField
//        userIDTextField.nextKeyView = passwordTextField
//        passwordTextField.nextKeyView = domainTextField
        
        // Init again
        if CRMCallManager.shareInstance.isShowLoginPage {
            domainTextField.stringValue = ""
            userIDTextField.stringValue = ""
            passwordTextField.stringValue = ""
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let isSaveID = defaults[CRMCallConfig.UserDefaultKey.SaveID] as? Int {
                isSaveIDCheckBox.state = isSaveID
            }
            
            if let isAutoLogin = defaults[CRMCallConfig.UserDefaultKey.AutoLogin] as? Int {
                isAutoLoginCheckBox.state = isAutoLogin
            }
        }
        
        if !flatRegisterNotification {
            flatDisconnect = true
            CRMCallManager.shareInstance.isShowLoginPage = true
            registerNotification()
        }
        
        if CRMCallManager.shareInstance.isShowSettingPage && flatShowSettingPage {
            CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController)
        }
        
        flatShowSettingPage = true
    }
    
    override func viewDidDisappear() {
        self.deregisterNotification()
        
        CRMCallManager.shareInstance.isShowLoginPage = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults[CRMCallConfig.UserDefaultKey.SaveID] = isSaveIDCheckBox.state
        defaults[CRMCallConfig.UserDefaultKey.AutoLogin] = isAutoLoginCheckBox.state
        
        KeyChainManager.shareInstance.saveUserInfo(withDomain: domainTextField.stringValue, userID: userIDTextField.stringValue, password: passwordTextField.stringValue)
    }
    
    deinit {
        deregisterNotification()
    }
    
    // MARK: - Notification
    struct Notification {
        static let LoginSuccess = "LoginSuccessNotification"
        static let LoginFaile = "LoginFaileNotification"
        static let LogoutSuccess = "LogoutSuccessNotification"
        static let Relogin = "ReloginNotification"
    }
    
    func registerNotification() {
        
        handlerNotificationSocketDisConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDisConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                CRMCallManager.shareInstance.deinitSocket()
                crmCallSocket.stopLiveTimer()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
            if (NSUserDefaults.standardUserDefaults()[CRMCallConfig.UserDefaultKey.SIPLoginResult] as! String) != "1" {
                self.showMessageSetting()
            }
            self.showAndStartProgress(false)
            
            self.flatDisconnect = true
        })
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if (self.isAutoLoginCheckBox.state == 0 || !self.isLoginManual) && !self.flatDisconnect { // USING FOR AUTO LOGIN
                return
            }
            
            CRMCallHelpers.reLoginSocket()
            
            self.flatDisconnect = false
        })
        
        handlerNotificationSocketLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.LoginSuccessSocket, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            CRMCallManager.shareInstance.isSocketLoginSuccess = true
            self.crmServerLogin()
        })
        
        handlerNotificationSocketLoginFail = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.LoginFailSocket, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallManager.shareInstance.isSocketLoginSuccess = false
            CRMCallManager.shareInstance.deinitSocket()
            self.showAndStartProgress(false)
            self.showMessageSetting()
        })

        handlerNotificationSocketLogoutSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LogoutSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallManager.shareInstance.isSocketLoginSuccess = false
            
            CRMCallManager.shareInstance.deinitSocket()
            self.showAndStartProgress(false)
        })
        
        handlerNotificationRevicedServerInfor = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.RecivedServerInfor, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.connect()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
        })
        
        handlerNotificationNotConnectInternet = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.NotConnetInternet, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
           self.showAndStartProgress(false)
        })
        
        handlerNotificationRelogin = NSNotificationCenter.defaultCenter().addObserverForName(LoginViewController.Notification.Relogin, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.actionLogin("")
        })
        
        flatRegisterNotification = true
    }
    
    func deregisterNotification() {
        if let notification = handlerNotificationSocketDisConnected {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationSocketDidConnected {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationSocketLoginSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationSocketLoginFail {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationRevicedServerInfor {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationNotConnectInternet {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationRelogin {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        if let notification = handlerNotificationSocketLogoutSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        flatRegisterNotification = false
    }
    
    // MARK: - Handling event
    @IBAction func actionLogin(sender: AnyObject) {
        
        if !CRMCallManager.shareInstance.isInternetConnect {
            self.showMessageNotConnectInternet()
            return
        }
        
        //GET SETTING INFO CHECK SETTING READEY
        let valueDict = KeyChainManager.shareInstance.getSettingInfo()
        
        guard let _ = valueDict[KeyChainManager.Keys.PhoneNumberSetting],
            host = valueDict[KeyChainManager.Keys.HostSetting],
            _ = valueDict[KeyChainManager.Keys.IDSetting],
            _ = valueDict[KeyChainManager.Keys.PasswordSetting] else {
            self.showMessageSetting()
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if self.domainTextField.stringValue != host {
            CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please check domain again", dismissText: "Ok", completion: { (result) in
            })
            return
        }
        
        if let sip = defaults[CRMCallConfig.UserDefaultKey.SIPLoginResult] as? String {
            if sip == "0" {
                showAndStartProgress(false)
                CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please setting phone number \nGo to Preferences...", dismissText: "Ok", completion: { (result) in
                })
                return
            }
        }
        
        showAndStartProgress(true)
        isLoginManual = true
      
        if CRMCallManager.shareInstance.isSocketLoginSuccess == false {
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {  // SIPLOGIN
                
                // Get port and host
                crmCallSocket.getIdAndHost(withHostName: host, Result: { (result) in
                    if !result {
                       self.showMessageNotConnectInternet()
                    }
                })
            } else {
                CRMCallManager.shareInstance.initSocket()
                if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                    
                    crmCallSocket.getIdAndHost(withHostName: host, Result: { (result) in
                        if !result {
                            self.showMessageNotConnectInternet()
                        }
                    })
                }
            }
        } else {
            crmServerLogin()
        }
    }
    
    // MARK: - Other func
    
    private func crmServerLogin() {
        
        let url = CRMCallConfig.API.login(with: domainTextField.stringValue)
        let parameter = RequestBuilder.login(userIDTextField.stringValue, password: passwordTextField.stringValue)
        
        AlamofireManager.requestUrlByPOST(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("----------->Login Data Success: \(datas)")
                
                guard let data = datas["data"] as? [String: AnyObject] else {
                    println("Cannot get data after login success")
                    return
                }
                
                CRMCallManager.shareInstance.isUserLoginSuccess = true
                
                if let sessionGW = data["session_gw"] as? String {
                    CRMCallManager.shareInstance.session_gw = sessionGW
                }
                
                if let sessionkey = data["session_key"] as? String {
                    CRMCallManager.shareInstance.session_key = sessionkey
                }
                
                if let cn = data["u_cn"] as? String {
                    CRMCallManager.shareInstance.cn = cn
                }
                
                CRMCallManager.shareInstance.domain = self.domainTextField.stringValue
                
                let mainViewController = MainViewController.createInstance()
                self.view.window?.contentViewController = mainViewController
            } else {
                CRMCallManager.shareInstance.isUserLoginSuccess = false
                
                self.showAndStartProgress(false)
                
                var msg = "Error login"
                if let message = datas["msg"] as? String {
                    msg = message
                }
                
                println("Message error: \(msg)")
                
                if let w = self.view.window {
                    CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle,window: w, title: "Notification", messageText: msg, dismissText: "Ok", completion: { result in })
                }
            }
        }
    }
    
    private func showMessageSetting() {
        showAndStartProgress(false)
    
        CRMCallAlert.showNSAlert(with: NSAlertStyle.InformationalAlertStyle, title: "Notification", messageText: "Please, call setting and again. \nGo to Preferences...", dismissText: "Ok", completion: { (result) in
        })
    }
    
    private func showMessageNotConnectInternet() {
        showAndStartProgress(false)
        if let w = self.view.window {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please check connect internet", dismissText: "Ok", completion: { result in })
        }
    }
    
    private func showAndStartProgress(state: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            if state {
                self.enableControl(state)
                self.progressLogin.startAnimation(self)
            } else {
                self.enableControl(state)
                self.progressLogin.stopAnimation(self)
            }
        }
    }
    
    private func enableControl(state: Bool) {
        _ = self.passwordTextField.stringValue
        _ = self.domainTextField.stringValue
        _ = self.userIDTextField.stringValue
        self.btnLogin.enabled = !state
        self.domainTextField.enabled = !state
        self.userIDTextField.enabled = !state
        self.passwordTextField.enabled = !state
        self.isSaveIDCheckBox.enabled = !state
        self.isAutoLoginCheckBox.enabled = !state
        self.progressLogin.hidden = !state
    }
    
}