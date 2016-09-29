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
    
    private var handlerNotificationSocketDisConnected: AnyObject!
    private var handlerNotificationSocketDidConnected: AnyObject!
    private var handlerNotificationSIPLoginSuccess: AnyObject!
    private var handlerNotificationSIPLoginFaile: AnyObject!
    private var handlerNotificationSIPHostFaile: AnyObject!
    
    let mainViewController = MainViewController.createInstance()
    
    // MARK: - Intialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("LoginViewControllerID") as! LoginViewController
    }
    
    func initData() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let isSaveID = defaults.objectForKey(CRMCallConfig.UserDefaultKey.SaveID) as? Int {
            if isSaveID == 1 {
                
                isSaveIDCheckBox.state = 1
                
                let hostSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.HostSetting) as? String
                let idSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.IDSetting) as? String
                
                self.domainTextField.stringValue = hostSetting ?? ""
                self.userIDTextField.stringValue = idSetting ?? ""
            }
        } else {
            defaults.setObject(isSaveIDCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.SaveID)
        }
        
        if let isAutoLogin = defaults.objectForKey(CRMCallConfig.UserDefaultKey.AutoLogin) as? Int {
            if isAutoLogin == 1 {
                
                isAutoLoginCheckBox.state = 1
                
                actionLogin("")
            }
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
    
    override func viewDidDisappear() {
        self.deregisterNotification()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(isSaveIDCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.SaveID)
        defaults.setObject(isAutoLoginCheckBox.state, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
        defaults.synchronize()
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
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
            
            if NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult) != "1" {
                self.showMessageSetting()
            }
        })
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
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
        })
        
        handlerNotificationSIPLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPLoginSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            self.crmServerLogin()
        })
        
        handlerNotificationSIPLoginFaile = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPLoginFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.showMessageSetting()
        })
        
        handlerNotificationSIPHostFaile = NSNotificationCenter.defaultCenter().addObserverForName(SettingViewController.Notification.SIPHostFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.showMessageSetting()
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDisConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDidConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPLoginSuccess)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPLoginFaile)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSIPHostFaile)
    }
    
    // MARK: - Handling event
    @IBAction func actionLogin(sender: AnyObject) {
        
        //GET SETTING INFO
        let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
        let hostSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.HostSetting) as? String
        let idSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.IDSetting) as? String
        let pwdSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PasswordSetting) as? String
        
        guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
            self.showMessageSetting()
            return
        }
        
        // SIPLOGIN
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            
            if crmCallSocket.isConnectedToHost == true {
                crmCallSocket.loginRequest(withUserID: id, passwold: pwd, phone: phone, domain: host)
                
            } else {
                println("Connect to server again.....")
                crmCallSocket.connect()
            }
        } else {
            CRMCallManager.shareInstance.initSocket()
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
                
                CRMCallManager.shareInstance.isLoginSuccess = true
                
                CRMCallManager.shareInstance.session_gw = data["session_gw"] as! String
                CRMCallManager.shareInstance.session_key = data["session_key"] as! String
                
                self.view.window?.contentViewController = self.mainViewController
            } else {
                CRMCallManager.shareInstance.isLoginSuccess = false
                
                if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                    crmCallSocket.logoutRequest()
                    crmCallSocket.stopLiveTimer()
                } else {
                    println("CRMCallManager.shareInstance.crmCallSocket = nil")
                }

                CRMCallAlert.showNSAlert(with: NSAlertStyle.WarningAlertStyle, title: "Notification", messageText: datas["msg"] as! String, dismissText: "Yes", completion: nil)
            }
        }
    }
    
    private func showMessageSetting() {
        CRMCallAlert.showNSAlert(with: NSAlertStyle.WarningAlertStyle, title: "Notification", messageText: "Please, call setting and again. \nGo to Preferences...", dismissText: "Yes", completion: nil)
    }
    
}