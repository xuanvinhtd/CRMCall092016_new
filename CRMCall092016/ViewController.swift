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
    private var socketManager: BaseSocket!
    
    private var handlerNotificationSocketDidConnected: AnyObject?
    private var handlerNotificationLoginSuccess: AnyObject?
    private var handlerNotificationLogoutSuccess: AnyObject?
    private var handlerNotificationConnectToHost: AnyObject?
    
    @IBOutlet weak var domanTextField: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var passTextField: NSSecureTextField!
    @IBOutlet weak var statusLogin: NSTextField!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotification()
        
        socketManager = CRMCallSocket()
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
        
        if socketManager.isConnectedToHost == true {
            
            requestLogin(withUserID: userTextField.stringValue, pass: passTextField.stringValue, domain: domanTextField.stringValue)
        } else {
            println("Waiting connect to server .....")
        }
        
    }
    
    @IBAction func actionLogout(sender: AnyObject) {
        
        if socketManager.isConnectedToHost == true {
            requestLogOut()
        } else {
            println("Disconnect to server")
        }

    }
    
    // MARK: - Notification
    struct Notification {
        static let loginSuccess = "LoginSuccessNotification"
        static let logoutSuccess = "LogoutSuccessNotification"
        static let connectToHost = "ConnectHostNotification"
    }
    
    private func registerNotification() {
        
        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil) { notification in
            
            println("\(notification)")
        }
        
        handlerNotificationLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.loginSuccess, object: nil, queue: nil) { notification in
            
            println("\(notification)")
            self.statusLogin.hidden = false
        }
        
        handlerNotificationLogoutSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.logoutSuccess, object: nil, queue: nil) { notification in
            
            println("\(notification)")
            self.statusLogin.hidden = true
        }
        
        handlerNotificationConnectToHost = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.connectToHost, object: nil, queue: nil) { notification in
            
            println("\(notification)")
            
            self.socketManager.connect()
        }
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
        
        if let notification = handlerNotificationConnectToHost {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
    }
    
    // MARK: - USER LOGIN/OUT
    private func requestLogin(withUserID userID: String, pass: String, domain: String) {
        
        let xmlLogin = XMLRequestBuilder.loginRequest(with: userID, pass: pass, domain: domain)
        
        socketManager.configData(withData: xmlLogin)
    }
    
    private func requestLogOut() {
        
    }
}

