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
        
       // dispatch_async(Cache.shareInstance.realmQueue, {
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
                            self.nameCaller.stringValue = "No Name VINH DEMO"
                            return
                        }
                        
                        let demoProduct = [
                            Product(value: ["idx":"1", "cn":"1", "name":"vinh", "code":"1234"]),
                            Product(value: ["idx":"2", "cn":"2", "name":"vinh1", "code":"1235"]),
                            Product(value: ["idx":"3", "cn":"3", "name":"vinh2", "code":"1236"]),
                            Product(value: ["idx":"5", "cn":"5", "name":"vinh4", "code":"1238"]),
                            Product(value: ["idx":"6", "cn":"3", "name":"vinh2", "code":"1236"]),
                            Product(value: ["idx":"7", "cn":"3", "name":"vinh2", "code":"1236"]),
                            Product(value: ["idx":"8", "cn":"3", "name":"vinh2", "code":"1236"]),
                            Product(value: ["idx":"9", "cn":"3", "name":"vinh2", "code":"1236"]),
                            Product(value: ["idx":"10", "cn":"3", "name":"vinh2", "code":"1236"]),
                            Product(value: ["idx":"11", "cn":"3", "name":"vinh2", "code":"1236"])
                        ]
                        
                        let demoStaff = [
                            Staff(value: ["no":"1", "cn":"5", "name":"Staftvinh1"]),
                            Staff(value: ["no":"2", "cn":"4", "name":"Staftvinh2"]),
                            Staff(value: ["no":"3", "cn":"6", "name":"Staftvinh3"]),
                            Staff(value: ["no":"4", "cn":"7", "name":"Staftvinh4"]),
                            Staff(value: ["no":"5", "cn":"7", "name":"Staftvinh4"]),
                            Staff(value: ["no":"6", "cn":"7", "name":"Staftvinh4"]),
                            Staff(value: ["no":"7", "cn":"7", "name":"Staftvinh4"]),
                            Staff(value: ["no":"8", "cn":"7", "name":"Staftvinh4"]),
                            Staff(value: ["no":"9", "cn":"7", "name":"Staftvinh4"]),
                            Staff(value: ["no":"10", "cn":"8", "name":"Staftvinh5"])
                        ]
                        
                        var strProduct = ""
                        var index = 0
                        
                        for product in demoProduct {
                            if index == 0 {
                                strProduct += product.name
                            } else {
                                strProduct += ", " + product.name
                            }
                            
                            index += 1
                        }
                        self.productsTextField.stringValue = strProduct
                        
                        var strStaff = ""
                        index = 0
                        
                        for staff in demoStaff {
                            if index == 0 {
                                strStaff += staff.name
                            } else {
                                strStaff += ", " + staff.name
                            }
                            
                            index += 1
                        }
                        
                        self.assignedTextField.stringValue = strStaff
                        
                        self.nameCaller.stringValue = userInfo.name
                    })
                }
                
                println("======> RingIng Info:\n \(_info.last)")
            })
     //   })
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
        self.view.window?.title = "Incoming call"
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