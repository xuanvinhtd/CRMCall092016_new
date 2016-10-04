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
    
    var flatDisconnect = false
    private var flatRegisterNotification = false
    
    // MARK: - Intialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("LoginViewControllerID") as! LoginViewController
    }
    
    func initData() {

        CRMCallManager.shareInstance.isShowLoginPage = true
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let isSaveID = defaults.objectForKey(CRMCallConfig.UserDefaultKey.SaveID) as? Int {
            if isSaveID == 1 {
                
                let domain = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.Domain) as? String
                let userID = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.UserID) as? String
                
                self.domainTextField.stringValue = domain ?? ""
                self.userIDTextField.stringValue = userID ?? ""
            }
            isSaveIDCheckBox.state = isSaveID
        } else {
            defaults.setObject(isSaveIDCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.SaveID)
        }
        
        if let isAutoLogin = defaults.objectForKey(CRMCallConfig.UserDefaultKey.AutoLogin) as? Int {
            if isAutoLogin == 1 {
                
                let domain = defaults.objectForKey(CRMCallConfig.UserDefaultKey.Domain) as? String
                let user = defaults.objectForKey(CRMCallConfig.UserDefaultKey.UserID) as? String
                let password = defaults.objectForKey(CRMCallConfig.UserDefaultKey.PasswordUser) as? String
                
                self.passwordTextField.stringValue = password ?? ""
                self.domainTextField.stringValue = domain ?? ""
                self.userIDTextField.stringValue = user ?? ""
                
                actionLogin("")
                showAndStartProgress(true)
            }
            isAutoLoginCheckBox.state = isAutoLogin
        } else {
            defaults.setObject(isAutoLoginCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
        }
    }
    
    // MARK: - View life cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init screen LoginViewController")
        
        registerNotification()
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Login"
        
        if !flatRegisterNotification {
            flatDisconnect = true
            CRMCallManager.shareInstance.isShowLoginPage = true
            registerNotification()
        }
    }
    
    override func viewDidDisappear() {
        self.deregisterNotification()
        
        CRMCallManager.shareInstance.isShowLoginPage = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(isSaveIDCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.SaveID)
        defaults.setObject(isAutoLoginCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
        
        defaults.setObject(domainTextField.stringValue, forKey: CRMCallConfig.UserDefaultKey.Domain)
        defaults.setObject(userIDTextField.stringValue, forKey: CRMCallConfig.UserDefaultKey.UserID)
        defaults.setObject(passwordTextField.stringValue, forKey: CRMCallConfig.UserDefaultKey.PasswordUser)
        defaults.synchronize()
    }
    
    deinit {
        deregisterNotification()
    }
    
    // MARK: - Notification
    struct Notification {
        static let LoginSuccess = "LoginSuccessNotification"
        static let LoginFaile = "LoginFaileNotification"
        static let LogoutSuccess = "LogoutSuccessNotification"
    }
    
    func registerNotification() {
        
        handlerNotificationSocketDisConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDisConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.logoutRequest()
                crmCallSocket.stopLiveTimer()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
            if NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult) != "1" {
                self.showMessageSetting()
            }
            self.showAndStartProgress(false)
            
            self.flatDisconnect = true
        })
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if self.isAutoLoginCheckBox.state != 1 && !self.flatDisconnect { // USING FOR AUTO LOGIN
                return
            }
            
            // GET SETTING INFO
            let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
            let hostSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.HostSetting) as? String
            let idSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.IDSetting) as? String
            let pwdSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PasswordSetting) as? String
            
            guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
                println("Please, call setting and again. \nGo to Preferences...")
                return
            }
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.loginRequest(withUserID: id, passwold: pwd, phone: phone, domain: host)
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
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
        
        flatRegisterNotification = true
    }
    
    func deregisterNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDisConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDidConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketLoginSuccess)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketLoginFail)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketLogoutSuccess)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRevicedServerInfor)
        
        flatRegisterNotification = false
    }
    
    // MARK: - Handling event
    @IBAction func actionLogin(sender: AnyObject) {

        showAndStartProgress(true)
        
        //GET SETTING INFO
        let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
        let hostSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.HostSetting) as? String
        let idSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.IDSetting) as? String
        let pwdSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PasswordSetting) as? String
        
        guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
            self.showMessageSetting()
            return
        }
        
        if CRMCallManager.shareInstance.isSocketLoginSuccess == false {
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {  // SIPLOGIN
                
                if crmCallSocket.isConnectedToHost == true {
                    crmCallSocket.loginRequest(withUserID: id, passwold: pwd, phone: phone, domain: host)
                    
                } else {
                    println("Connect to server again.....")
                    crmCallSocket.connect()
                }
            } else {
                CRMCallManager.shareInstance.initSocket()
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
                println("-----------> Data Login Success = \(datas)")
                
                guard let data = datas["data"] as? [String: AnyObject] else {
                    println("Cannot get data after login success")
                    return
                }
                
                CRMCallManager.shareInstance.isUserLoginSuccess = true
                
                CRMCallManager.shareInstance.session_gw = data["session_gw"] as! String
                CRMCallManager.shareInstance.session_key = data["session_key"] as! String
                CRMCallManager.shareInstance.domain = self.domainTextField.stringValue
                
                let mainViewController = MainViewController.createInstance()
                self.view.window?.contentViewController = mainViewController
            } else {
                CRMCallManager.shareInstance.isUserLoginSuccess = false
                
                self.showAndStartProgress(false)
                
                CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: datas["msg"] as! String, dismissText: "Cancel", completion: { result in })
            }
        }
    }
    
    private func showMessageSetting() {
        CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Please, call setting and again. \nGo to Preferences...", dismissText: "Cancel", completion: { result in })
    }
    
    private func showAndStartProgress(state: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            if state {
                self.btnLogin.enabled = !state
                self.progressLogin.hidden = !state
                self.progressLogin.startAnimation(self)
            } else {
                self.btnLogin.enabled = !state
                self.progressLogin.hidden = !state
                self.progressLogin.stopAnimation(self)
            }
        }
    }
    
}