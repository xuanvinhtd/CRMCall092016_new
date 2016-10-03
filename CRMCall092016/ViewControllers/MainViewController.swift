//
//  MainViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/28/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController  , ViewControllerProtocol{
    
    // MARK: - Properties
    @IBOutlet weak var missCallNumber: NSTextField!
    
    private var handlerNotificationRingIng: AnyObject!
    private var handlerNotificationShowPageRingIng: AnyObject!
    private var handlerNotificationShowPageSigIn: AnyObject!
    private var handlerNotificationSocketDisConnected: AnyObject!
    private var handlerNotificationSocketLogoutSuccess: AnyObject!
    
    
    @IBOutlet weak var lastPhoneCombobox: NSPopUpButtonCell!
    @IBOutlet weak var searchButton: NSButton!
    
    
    private var missCallNumbers = 0
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("MainViewControllerID") as! MainViewController
    }
    
    func initData() {
        CRMCallManager.shareInstance.isShowMainPage = true
        
        loadDataCombobox()
    }
    
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init MainViewController Screen")
        registerNotification()
        
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "CRMCAll"
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
    }
    
    deinit {
        deregisterNotification()
    }
    
    // MARK: - Notification
    struct Notification {
        static let ShowPageSigin = "ShowPageSigin"
    }
    
    func registerNotification() {
        handlerNotificationSocketDisConnected = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.SocketDisConnected, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            println("----------------xxxxx--DISCONNECT SOCKET TO SERVER--xxxxx--------------------")
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                crmCallSocket.logoutRequest()
                crmCallSocket.stopLiveTimer()
            } else {
                println("CRMCallManager.shareInstance.crmCallSocket = nil")
            }
        })
        
        handlerNotificationRingIng = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.RingIng, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            guard let userInfo = notification.userInfo else {
                println("Not found the userInfo to get info of user")
                return
            }
            
            let callID =  userInfo["CALLID"] as! String
            let phoneNumber =  userInfo["FROM"] as! String
            let event = userInfo["EVENT"] as! String
            
            if event == CRMCallHelpers.Event.Invite.rawValue {
                CRMCallManager.shareInstance.crmCallSocket?.getUserInfoRequest(with: callID, phonenumber: phoneNumber)
            }
            
            if event == CRMCallHelpers.Event.Cancel.rawValue {
                NSNotificationCenter.defaultCenter().postNotificationName(RingIngViewController.Notification.RingCancel, object: nil, userInfo: ["STATUS":"Cancel call."])
                
                self.missCallNumbers += 1
                self.missCallNumber.stringValue = String(self.missCallNumbers)
                
                self.loadDataCombobox()
                
                CRMCallManager.shareInstance.myCurrentStatus = .None
                
                if let viewControllerArr = self.presentedViewControllers {
                    for viewController: NSViewController in viewControllerArr {
                        if viewController.isKindOfClass(RingIngViewController) {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.dismissViewController(viewController)
                            })
                        }
                    }
                }
            }
        })
        
        handlerNotificationShowPageRingIng = NSNotificationCenter.defaultCenter().addObserverForName(RingIngViewController.Notification.Show, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if CRMCallManager.shareInstance.myCurrentStatus == .None {
                
                CRMCallManager.shareInstance.myCurrentStatus = CRMCallHelpers.UserStatus.Ringing
                
                dispatch_async(dispatch_get_main_queue(), {
                    let ringViewController = RingIngViewController.createInstance()
                    self.presentViewControllerAsModalWindow(ringViewController)
                })
            }
        })
        
        handlerNotificationShowPageSigIn = NSNotificationCenter.defaultCenter().addObserverForName(MainViewController.Notification.ShowPageSigin, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.deregisterNotification()
            
            let loginViewController = LoginViewController.createInstance() as! LoginViewController
            loginViewController.flatDisconnect = true
            self.view.window?.contentViewController = loginViewController
        })
        
        handlerNotificationSocketLogoutSuccess = NSNotificationCenter.defaultCenter().addObserverForName(ViewController.Notification.LogoutSuccess, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            CRMCallManager.shareInstance.isSocketLoginSuccess = false
            CRMCallManager.shareInstance.deinitSocket()
            
            println("----------------xxxx---RECONNET SOCKET TO SERVER---xxxx------------")
            CRMCallHelpers.reconnectToSocket()
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDisConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRingIng)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationShowPageRingIng)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationShowPageSigIn)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketLogoutSuccess)
    }
    
    // MARK: - Handling event
    
    @IBAction func acctionSearch(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            let ringViewController = RingIngViewController.createInstance()
            self.presentViewControllerAsModalWindow(ringViewController)
        })
    }
    
    // MARK: - Private func
    private func loadDataCombobox() {
        Cache.shareInstance.getRingInfo { data in
            guard let _data = data else {
                println("Not found data Ring info")
                return
            }
            
            if let ringList = _data.valueForKeyPath("from") as! NSArray? {
                
                var mySet = Set<String>()
                mySet.unionInPlace(ringList.map { $0 as! String })
                
                dispatch_async(dispatch_get_main_queue(), {
                    for ring in mySet {
                        self.lastPhoneCombobox.addItemWithTitle(ring)
                    }
                })
            }
            
        }
    }
    
}
