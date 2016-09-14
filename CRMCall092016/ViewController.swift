//
//  ViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Properties
    private var crmCallSocket: CRMCallSocket!
    
    private var handlerNotificationSocketDidConnected: AnyObject?
    private var handlerNotificationLoginSuccess: AnyObject?
    private var handlerNotificationLogoutSuccess: AnyObject?
    private var handlerNotificationRevicedServerInfor: AnyObject?
    
    @IBOutlet weak var domanTextField: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var passTextField: NSSecureTextField!
    @IBOutlet weak var statusLogin: NSTextField!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotification()
        
        crmCallSocket = CRMCallSocket()
    }

    deinit {
        deRegisterNotification()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // MARK: - Handling event
    
    @IBAction func actionLogin(sender: AnyObject) {
        
        if crmCallSocket.isConnectedToHost == true {
            
            crmCallSocket.requestLogin(withUserID: userTextField.stringValue, passwold: passTextField.stringValue, domain: domanTextField.stringValue)

        } else {
            println("Please connect to server .....")
        }
        
    }
    
    @IBAction func actionLogout(sender: AnyObject) {
        
        if crmCallSocket.isConnectedToHost == true {
            crmCallSocket.requestLogout()
        } else {
            println("Disconnect to server")
        }

    }
    
    // MARK: - Notification
    struct Notification {
        static let LoginSuccess = "LoginSuccessNotification"
        static let LogoutSuccess = "LogoutSuccessNotification"
    }
    
    private func registerNotification() {
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
        })
        
        handlerNotificationLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LoginSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            self.statusLogin.hidden = false
        })
        
        handlerNotificationLogoutSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LogoutSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            self.statusLogin.hidden = true
        })
        
        handlerNotificationRevicedServerInfor = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.RecivedServerInfor, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            self.crmCallSocket.connect()
        })
    }
    
    private func deRegisterNotification() {
        
        if let notification = handlerNotificationSocketDidConnected {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationLoginSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationLogoutSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationRevicedServerInfor {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
    }
}

