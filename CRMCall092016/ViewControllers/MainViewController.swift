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
        
        //testAPI()
    }
    
    func testAPI() {
        
        ///////////------Search customer---------------/////////////
        let types = [CRMCallHelpers.TypeApi.Company.rawValue
            // CRMCallHelpers.TypeApi.Contact.rawValue,
            //CRMCallHelpers.TypeApi.Employee.rawValue
        ]
        let pages  = ["1", "10"]
        let url = CRMCallConfig.API.searchCustomer(withCompany: "102", types: types, pages: pages, keyword: "", sort: CRMCallHelpers.Sort.Name.rawValue, order: CRMCallHelpers.Order.Desc.rawValue)
        
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("-----------> SEARCH CUSTOMER DATA CALL RESPONCE: \(datas)")
                
                if let data = datas["rows"] as? [String: AnyObject] {
                    println("SEARCH CUSTOMER DATA CALL GET FROM SERVER ----> \(data)")
                } else {
                    println("Not found SEARCH CUSTOMER from server")
                }
                
                
            } else {
                println("---XXXXX---->>> GET DATA SEARCH CUSTOMER FAIL WITH MESSAGE: \(datas)")
            }
        }
        
        
        //        //////////////-----------Register employee-----------/////////////
        //        let info = CRMCallHelpers.createDictionaryEmployee(withData: ["vinh label"], phoneNumber: ["01667289026"])
        //        let parameter1 = RequestBuilder.registerEmployee(withName: "VINH KILLER", info: info)
        //
        //        let url1 = CRMCallConfig.API.registerEmployee(withCompany: "102", companyCode: "ACCT-6484-00014")
        //
        //        AlamofireManager.requestUrlByPOST(withURL: url1, parameter: parameter1) { (datas, success) in
        //            if success {
        //                println("-----------> Register employee data responce: \(datas)")
        //
        ////                guard let data = datas["rows"] as? [String: AnyObject] else {
        ////                    println("Cannot get data after register employee success")
        ////                    return
        ////                }
        //            } else {
        //                println("---XXXXX---->>> Register employee data fail with message: \(datas)")
        //            }
        //        }
        
        
        //        ///-------------- REGISTER NEW PHONE OF COMPANY-------------//
        //        let parameter2 = CRMCallHelpers.createDictionaryTelephoneOfSomeOne(withData: "1", phoneNumber: "1111111", cateID: "400", cn: "102")
        //
        //        let url2 = CRMCallConfig.API.registerTelephoneOfCompany(withCompany: "102", companyCode: "ACCT-6484-00014")
        //
        //        AlamofireManager.requestUrlByPUT(withURL: url2, parameter: parameter2) { (datas, success) in
        //            if success {
        //                println("-----------> Register telephone of company data responce: \(datas)")
        //
        //                //                guard let data = datas["rows"] as? [String: AnyObject] else {
        //                //                    println("Cannot get data after register employee success")
        //                //                    return
        //                //                }
        //            } else {
        //                println("---XXXXX---->>> Register telephone of company data fail with message: \(datas)")
        //            }
        //        }
        
        
        
        
        //        ///-------------- REGISTER NEW PHONE OF EMPLOYEE-------------//
        //        let parameter3 = CRMCallHelpers.createDictionaryTelephoneOfSomeOne(withData: "2", phoneNumber: "01667289000", cateID: "400", cn: "102")
        //
        //        let url3 = CRMCallConfig.API.registerTelephoneForEmployee(withCompany: "102", employeeCode: "CONT-6484-00039")
        //
        //        AlamofireManager.requestUrlByPUT(withURL: url3, parameter: parameter3) { (datas, success) in
        //            if success {
        //                println("-----------> Register telephone of company data responce: \(datas)")
        //
        //                //                guard let data = datas["rows"] as? [String: AnyObject] else {
        //                //                    println("Cannot get data after register employee success")
        //                //                    return
        //                //                }
        //            } else {
        //                println("---XXXXX---->>> Register telephone of company data fail with message: \(datas)")
        //            }
        //        }
        
        
        ///-------------- REGISTER LABEL -------------//
        //        let parameter4 = CRMCallHelpers.createDictionaryRegisterManually(withData: "1", labelValue: "vinh cute 123", phoneNumber: "01667289999", cateID: "400", cn: "102")
        //        let url4 = CRMCallConfig.API.registerWithLabel(withCompany: "1", companyCode: "ACCT-6484-00014")
        //
        //        AlamofireManager.requestUrlByPUT(withURL: url4, parameter: parameter4) { (datas, success) in
        //            if success {
        //                println("-----------> Register label data responce: \(datas)")
        //
        //                //                guard let data = datas["rows"] as? [String: AnyObject] else {
        //                //                    println("Cannot get data after register employee success")
        //                //                    return
        //                //                }
        //            } else {
        //                println("---XXXXX---->>> Register label data fail with message: \(datas)")
        //            }
        //        }
        
        
        ///-------------- SEARCH API -------------//
        //        let url5 = CRMCallConfig.API.searchHistoryCall(withCompany: "102", limit: 25, offset: 0, sort: CRMCallHelpers.Sort.DateTime.rawValue, order: CRMCallHelpers.Order.Desc.rawValue, since: "2015-09-28T00:00:00+9", until: "2016-10-28T00:00:00+9", dateRange: CRMCallHelpers.Sort.DateTime.rawValue, type: CRMCallHelpers.TypeApi.Call.rawValue)
        //
        //        AlamofireManager.requestUrlByGET(withURL: url5, parameter: nil) { (datas, success) in
        //            if success {
        //                println("-----------> Search history Call data responce: \(datas)")
        //
        //                //                guard let data = datas["rows"] as? [String: AnyObject] else {
        //                //                    println("Cannot get data after register employee success")
        //                //                    return
        //                //                }
        //            } else {
        //                println("---XXXXX---->>> Get Search history Call data fail with message: \(datas)")
        //            }
        //        }
        
        
        ///-------------- SEARCH API CUSTOMER IN CALL HISTORY-------------//
        let types6 = [CRMCallHelpers.TypeApi.Call.rawValue,
                      CRMCallHelpers.TypeApi.Meeting.rawValue,
                      CRMCallHelpers.TypeApi.Fax.rawValue,
                      CRMCallHelpers.TypeApi.Post.rawValue,
                      CRMCallHelpers.TypeApi.Appointment.rawValue,
                      CRMCallHelpers.TypeApi.Task.rawValue,
                      CRMCallHelpers.TypeApi.Sms.rawValue,
                      CRMCallHelpers.TypeApi.Email.rawValue
        ]
        let url6 = CRMCallConfig.API.searchHistoryCallOfCustomer(withCompany: "102", customerCode: "CONT-6484-00013", limit: 21, offset: 0, sort: CRMCallHelpers.Sort.DateTime.rawValue, order: CRMCallHelpers.Order.Desc.rawValue, type: types6)
        
        AlamofireManager.requestUrlByGET(withURL: url6, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Search history Call of customer data responce: \(datas)")
                
                guard let data = datas["rows"] as? [String: AnyObject] else {
                    println("Cannot get data after register employee success")
                    return
                }
                
            } else {
                println("---XXXXX---->>> Get Search history Call of customer data fail with message: \(datas)")
            }
        }
        
        ///-------------- GET ALL STAFF -------------//
        
        let url7 = CRMCallConfig.API.getAllStaffs()
        
        AlamofireManager.requestUrlByGET(withURL: url7, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Get All Staff data responce: \(datas)")
                
                //                guard let data = datas["rows"] as? [String: AnyObject] else {
                //                    println("Cannot get data after register employee success")
                //                    return
                //                }
            } else {
                println("---XXXXX---->>> Get all staff data fail with message: \(datas)")
            }
        }
        
        
        
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
            if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                let phoneNumber =  userInfo["FROM"] as! String
                CRMCallManager.shareInstance.crmCallSocket?.getUserInfoRequest(with: callID, phonenumber: phoneNumber)
            } else {
                let phoneNumber =  userInfo["TO"] as! String
                CRMCallManager.shareInstance.crmCallSocket?.getUserInfoRequest(with: callID, phonenumber: phoneNumber)
            }
        })
        
        handlerNotificationInviteResultEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.InviteResultEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            dispatch_async(dispatch_get_main_queue(), {
                if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                    if let historyWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] {
                        historyWindowController.showWindow(nil)
                    } else {
                        let historyWindowController = HistoryCallWindowController.createInstance()
                        historyWindowController.showWindow(nil)
                        CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] = historyWindowController
                    }
                } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
                    
                }
            })
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
