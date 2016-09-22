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
    private var isAutoLogin = false
    
    private var handlerNotificationSocketDisConnected: AnyObject?
    private var handlerNotificationSocketDidConnected: AnyObject?
    private var handlerNotificationLoginSuccess: AnyObject?
    private var handlerNotificationLoginFaile: AnyObject?
    private var handlerNotificationLogoutSuccess: AnyObject?
    private var handlerNotificationRevicedServerInfor: AnyObject?
    
    @IBOutlet weak var domanTextField: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var passTextField: NSSecureTextField!
    @IBOutlet weak var statusLogin: NSTextField!
    
    @IBOutlet weak var phoneTextField: NSTextField!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registerNotification()
    }

    deinit {
        //deRegisterNotification()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // MARK: - Handling event
    
    @IBAction func actionLogin(sender: AnyObject) {
        
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            
            if crmCallSocket.isConnectedToHost == true {
                
                crmCallSocket.requestLogin(withUserID: userTextField.stringValue, passwold: passTextField.stringValue, phone: phoneTextField.stringValue, domain: domanTextField.stringValue)
                
            } else {
                println("Please connect to server .....")
            }
        } else {
            CRMCallManager.shareInstance.initSocket()
            self.isAutoLogin = true
        }
    }
    
    @IBAction func actionLogout(sender: AnyObject) {
        
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            
            if crmCallSocket.isConnectedToHost == true {
                crmCallSocket.requestLogout()
            } else {
                println("Disconnect to server")
            }
        } else {
            println("CRMCallSocket not init")
        }
        
        self.isAutoLogin = false
    }
    
    // MARK: - Notification
    struct Notification {
        static let LoginSuccess = "LoginSuccessNotification"
        static let LoginFaile = "LoginFaileNotification"
        static let LogoutSuccess = "LogoutSuccessNotification"
    }
    
    private func registerNotification() {
        
        handlerNotificationSocketDisConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDisConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.requestLogout()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
        })

        handlerNotificationSocketDidConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDidConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if self.isAutoLogin {
                if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                    crmCallSocket.requestLogin(withUserID: self.userTextField.stringValue, passwold: self.passTextField.stringValue, phone: self.phoneTextField.stringValue, domain: self.domanTextField.stringValue)
                } else {
                    println("CRMCallManager.shareInstance.crmCallSocket = nil")
                }
            }
        })
        
        handlerNotificationLoginSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LoginSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            self.statusLogin.hidden = false
        })
        
        handlerNotificationLoginFaile = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LoginFaile, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            dispatch_async(dispatch_get_main_queue(), { 
                self.shack()
            })
        })
        
        handlerNotificationLogoutSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LogoutSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallManager.shareInstance.deinitSocket()
            dispatch_async(dispatch_get_main_queue(), {
                self.statusLogin.hidden = true
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
        
        if let notification = handlerNotificationLoginSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationLoginFaile {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationLogoutSuccess {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
        
        if let notification = handlerNotificationRevicedServerInfor {
            NSNotificationCenter.defaultCenter().removeObserver(notification)
        }
    }
    
    func shack() {
        let numberOfShakes:Int = 8
        let durationOfShake:Float = 0.5
        let vigourOfShake:Float = 0.05
        
        let frame:CGRect = (self.view.window?.frame)!
        let shakeAnimation = CAKeyframeAnimation()
        
        let shakePath = CGPathCreateMutable()
        CGPathMoveToPoint(shakePath, nil, NSMinX(frame), NSMinY(frame))
        
        for _ in 1...numberOfShakes{
            CGPathAddLineToPoint(shakePath, nil, NSMinX(frame) - frame.size.width * CGFloat(vigourOfShake), NSMinY(frame))
            CGPathAddLineToPoint(shakePath, nil, NSMinX(frame) + frame.size.width * CGFloat(vigourOfShake), NSMinY(frame))
        }
        
        CGPathCloseSubpath(shakePath)
        shakeAnimation.path = shakePath
        shakeAnimation.duration = CFTimeInterval(durationOfShake)
        self.view.window?.animations = ["frameOrigin":shakeAnimation]
        self.view.window?.animator().setFrameOrigin(self.view.window!.frame.origin)
    }
}

