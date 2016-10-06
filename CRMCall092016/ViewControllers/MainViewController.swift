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
    
    private var handlerNotificationInviteEvent: AnyObject!
    private var handlerNotificationInviteResultEvent: AnyObject!
    private var handlerNotificationCancelEvent: AnyObject!
    private var handlerNotificationBusyEvent: AnyObject!
    private var handlerNotificationByeEvent: AnyObject!
    
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
        
        handlerNotificationShowPageRingIng = NSNotificationCenter.defaultCenter().addObserverForName(RingIngViewController.Notification.Show, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                    
                    if let ringWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.RingIngWindowController] {
                        ringWindowController.showWindow(nil)
                    } else {
                        let ringWindowController = RingIngWindowController.createInstance()
                        ringWindowController.showWindow(nil)
                        CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.RingIngWindowController] = ringWindowController
                    }
                } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
                    
                    if let historyWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] {
                        historyWindowController.showWindow(nil)
                    } else {
                        let historyWindowController = HistoryCallWindowController.createInstance()
                        historyWindowController.showWindow(nil)
                        CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] = historyWindowController
                    }
                }
            })
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
        
        handlerNotificationInviteEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.InviteEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            guard let userInfo = notification.userInfo else {
                println("Not found the userInfo to get info of user")
                return
            }
            // Get info user
            let callID =  userInfo["CALLID"] as! String
            let phoneNumber =  userInfo["FROM"] as! String
            CRMCallManager.shareInstance.crmCallSocket?.getUserInfoRequest(with: callID, phonenumber: phoneNumber)
        })
        
        handlerNotificationInviteResultEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.InviteResultEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let historyWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] {
                historyWindowController.showWindow(nil)
            } else {
                let historyWindowController = HistoryCallWindowController.createInstance()
                historyWindowController.showWindow(nil)
                CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] = historyWindowController
            }
        })
        
        handlerNotificationBusyEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.BusyEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            dispatch_async(dispatch_get_main_queue(), {
                if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                    
                    if let loginWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.RingIngWindowController] {
                        loginWindowController.close()
                        CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.RingIngWindowController)
                    }
                    
                } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
                    
                }
            })

        })
        
        handlerNotificationCancelEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.CancelEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.missCallNumbers += 1
            self.missCallNumber.stringValue = String(self.missCallNumbers)
            
            self.loadDataCombobox()
            dispatch_async(dispatch_get_main_queue(), {
                if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                    
                    if let loginWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.RingIngWindowController] {
                        loginWindowController.close()
                        CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.RingIngWindowController)
                    }
                    
                } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
                    
                }
            })
        })
        
        handlerNotificationByeEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.ByeEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.loadDataCombobox()
            
            if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                
                if let loginWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.RingIngWindowController] {
                    loginWindowController.close()
                    CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.RingIngWindowController)
                }

            } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
                
            }
        })
        
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketDisConnected)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationShowPageRingIng)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationShowPageSigIn)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationSocketLogoutSuccess)
        
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationInviteEvent)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationInviteResultEvent)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationByeEvent)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationBusyEvent)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationCancelEvent)
    }
    
    // MARK: - Handling event
    
    @IBAction func acctionSearch(sender: AnyObject) {
        //        dispatch_async(dispatch_get_main_queue(), {
        //            let ringViewController = RingIngViewController.createInstance()
        //            self.presentViewControllerAsModalWindow(ringViewController)
        //        })
        
        // dispatch_async(dispatch_get_main_queue(), {
        if let historyWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] {
            historyWindowController.showWindow(nil)
        } else {
            let historyWindowController = HistoryCallWindowController.createInstance()
            historyWindowController.showWindow(nil)
            CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] = historyWindowController
        }
        
        //   })
        
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
