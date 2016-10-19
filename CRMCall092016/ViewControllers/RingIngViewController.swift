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
    
    @IBOutlet weak var productsTextField: NSTextField!
    @IBOutlet weak var assignedTextField: NSTextField!
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("RingIngViewControllerID") as! RingIngViewController
    }
    
    func initData() {
        
            Cache.shareInstance.getRingInfo({ info in
                
                guard let _info = info else {
                    println("======> RingIng Info: NULL")
                    self.phoneCaller.stringValue = "0"
                    return
                }
                self.phoneCaller.stringValue = (_info.last?.from)!
                
                if let idCall = (_info.last?.callID) {
                    
                    Cache.shareInstance.getCustomerInfo(with:  NSPredicate(format: "idx = %@", idCall), Result: { userInfo in
                        
                        guard let userInfo = userInfo?.first else {
                            println("Not found Info CallID of \(_info.last?.from) and CallID: \(idCall)")
                            self.nameCaller.stringValue = ""
                            return
                        }
                        
                        if userInfo.phone == "0" { // User not register
                            
                            if let infoRing = _info.last {
                                self.phoneCaller.stringValue = infoRing.from
                            }
                            
                        } else { // User regestered
                            self.nameCaller.stringValue = userInfo.name
                            self.phoneCaller.stringValue = userInfo.phone
                            
                            var productNames = [String]()
                            for product in userInfo.products {
                                productNames.append(product.name)
                            }
                            self.productsTextField.stringValue = productNames.joinWithSeparator(",")
                            
                            
                            var staffNameList = [String]()
                            for staff in userInfo.staffs {
                                staffNameList.append(staff.name)
                            }
                            self.assignedTextField.stringValue = staffNameList.joinWithSeparator(",")
                        }
                    })
                }
                
                println("======> RingIng Info:\n \(_info.last)")
            })
    }
    
    // MARK: - Initialzation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init Screen RingIngViewController")
        
        initData()
        
        registerNotification()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Call"
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
               //self.statusCall.stringValue = userInfo["STATUS"] as! String
            }
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationRingCancel)
    }
    
}