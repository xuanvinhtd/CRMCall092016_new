//
//  RingIngViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/23/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class RingIngViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    private var handlerNotificationRingCancel: AnyObject!
    
    @IBOutlet weak var nameCaller: NSTextField!
    @IBOutlet weak var phoneCaller: NSTextField!
    @IBOutlet weak var statusCall: NSTextField!
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("RingIngViewControllerID") as! RingIngViewController
    }
    
    func initData() {
        statusCall.stringValue = "Ring Ring..."
        
        dispatch_async(dispatch_get_main_queue(), {
            if let info = Cache.shareInstance.getRingInfo() {
                self.phoneCaller.stringValue = (info.last?.from)!
                
                if let idCall = (info.last?.callID) {
                    if let userInfo = Cache.shareInstance.getCustomerInfo(with: NSPredicate(format: "idx = %@", idCall))?.first {
                        self.nameCaller.stringValue = userInfo.name
                    } else {
                        println("Not found CallID of \(info.last?.from) and CallID: \(idCall)")
                        self.nameCaller.stringValue = "No Name"
                    }
                }
                
                println("======> RingIng Info:\n \(info.last)")
            } else {
                println("======> RingIng Info: NULL")
                self.phoneCaller.stringValue = "0"
            }
        })
    }
    
    // MARK: - Initialzation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init Screen RingIngViewController")
        
        initData()
        
        registerNotification()
    }
    
    override func viewDidDisappear() {
        deregisterNotification()
    }
    
    // MARK: - Notification
    struct Notification {
        static let RingCancel = "RingCancel"
        static let RingBusy = "RingBusy"
        static let Show = "Show"
    }
    
    func registerNotification() {
        handlerNotificationRingCancel = NSNotificationCenter.defaultCenter().addObserverForName(RingIngViewController.Notification.RingCancel, object: nil, queue: nil, usingBlock: { notification in
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if let userInfo = notification.userInfo {
               self.statusCall.stringValue = userInfo["STATUS"] as! String
            }
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRingCancel)
    }
    
}