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
    
    private var missCallNumbers = 0
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("MainViewControllerID") as! MainViewController
    }
    
    func initData() {
        CRMCallManager.shareInstance.isShowMainPage = true
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
        
        CRMCallManager.shareInstance.deinitSocket()
    }
    
    // MARK: - Notification
    struct Notification {
        static let ShowPageSigin = "ShowPageSigin"
    }
    
    func registerNotification() {
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
            
            let loginViewController = LoginViewController.createInstance()
            self.view.window?.contentViewController = loginViewController
        })

    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRingIng)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationShowPageRingIng)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationShowPageSigIn)
    }
    
}
