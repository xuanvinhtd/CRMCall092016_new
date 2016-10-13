//
//  HistoryCallViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/30/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa
import Chronos

class HistoryCallViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    @IBOutlet weak var phoneTextField: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var companyTextField: NSTextField!

    @IBOutlet weak var phoneTypePopUpBtn: NSComboBox!
    @IBOutlet weak var typeCallLabel: NSTextField!
    
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var priorityPopUpBtn: NSPopUpButton!
    @IBOutlet weak var assignedTextFeild: NSTextField!
    @IBOutlet var noteTextView: NSTextView!
    @IBOutlet weak var purposeTextField: NSTextField!
    @IBOutlet weak var productTextField: NSTextField!
    @IBOutlet weak var subjectTextField: NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var addTaskButton: NSButton!
    @IBOutlet weak var createTicketButton: NSButton!
    @IBOutlet weak var historyButton: NSButton!
    
    @IBOutlet weak var historyTableView: NSTableView!
    
    @IBOutlet weak var panelGeneral: NSView!
    @IBOutlet weak var panelDetail: NSView!
    @IBOutlet weak var durationsTextField: NSTextField!
    
    private var purposeID = "purposeID"
    private var subjectID = "SubjectID"
    
    private var addressDict = ["":""]
    private var priorityDict = ["":""]

    private var purposeDict = [NSMutableDictionary]()
    private var productDict = [NSMutableDictionary]()
    private var productCodeOfCustomer = [String]()
    
    private var dataHistoryDict = [[String : AnyObject]]()
    
    private var timer: DispatchTimer!
    
    private var staffDict = [[String : AnyObject]]()
    private var customerDict = [[String : AnyObject]]()
    
    private var customerSelect = [String : AnyObject]()
    
    private var isUnRegister = false

    private var indexTypePhone = 0
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        var popUpViewController = PopUpViewController(nibName: "PopUpViewController", bundle: nil)
        popover.contentViewController = popUpViewController
        popover.delegate = self
        return popover
    }()
    
    private var handlerNotificationByeEvent: AnyObject!
    private var handlerNotificationInviteResultEvent: AnyObject!
    private var handlerNotificationCancelEvent: AnyObject!
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("HistoryCallViewControllerID") as! HistoryCallViewController
    }
    
    func initData() {
        
        self.timer = DispatchTimer(interval: 1.0, closure: {
            (timer: RepeatingTimer, count: Int) in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.durationsTextField.stringValue = String(count) + "s"
            })
        })
        self.durationsTextField.stringValue = String(0) + "s"
        if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
            self.timer.start(true)
        }
        
        if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
            typeCallLabel.stringValue = "[Incoming]"
        } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
            typeCallLabel.stringValue = "[Outcoming]"
        } else {
            typeCallLabel.stringValue = "[None]"
        }
        
        priorityDict = ["1":"★", "2":"★★", "3":"★★★", "4":"★★★★", "5":"★★★★★"]
        var values = Array(priorityDict.values)
        values = values.sort()
        priorityPopUpBtn.addItemsWithTitles(values)
        
        dateTextField.stringValue = NSDate().stringFormattedDateTime
        
        // GET TYPE PHONE
        var url = CRMCallConfig.API.phoneType()
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("----------->Type phone data responce: \(datas)")
                
                if let address = datas["address"] as? [String: String] {
                    self.addressDict = address
                    
                    let arrString = Array(address.values)
                    for str in arrString {
                        self.phoneTypePopUpBtn.addItemWithObjectValue(str)
                    }
                    
                    let index = self.indexTypePhone == 0 ? self.indexTypePhone : self.indexTypePhone - 1
                    self.phoneTypePopUpBtn.selectItemAtIndex(index)
                    
                } else {
                    println("Not found address from server")
                }
                
            } else {
                println("---XXXXX---->>> Get data type phone fail with message: \(datas)")
            }
        }
        
        // GET PURPOSE LIST
        url = CRMCallConfig.API.purposeList(withCNKey: CRMCallManager.shareInstance.cn)
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                if let data = datas["rows"] as? [[String: String]] {
                    self.purposeDict = self.buildDictionary(withValue: data, isPurpose: true)
                } else {
                    println("Not found purpose list from server")
                }
            } else {
                println("---XXXXX---->>> Get purpose data fail with message: \(datas)")
            }
        }
        
        // GET PRODUCT LIST
        url = CRMCallConfig.API.productList(withCNKey: CRMCallManager.shareInstance.cn)
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Product data responce: \(datas)")
                
                if let data = datas["rows"] as? [[String: String]] {
                    self.productDict = self.buildDictionary(withValue: data, isPurpose: false)
                } else {
                    println("Not found product list from server")
                }
            } else {
                println("---XXXXX---->>> get product data fail with messgae: \(datas)")
            }
        }
        
        Cache.shareInstance.getRingInfo({ info in
            
            guard let _info = info else {
                println("======> RingIng Info: NULL")
                self.phoneTextField.stringValue = "0"
                return
            }
            
            if let idCall = (_info.last?.callID) {
                
                Cache.shareInstance.getCustomerInfo(with:  NSPredicate(format: "idx = %@", idCall), Result: { userInfo in
                    
                    guard let userInfo = userInfo?.first else {
                        println("Not found Info CallID of \(_info.last?.from) and CallID: \(idCall)")
                        self.nameTextField.stringValue = ""
                        return
                    }
                    
                    if userInfo.phone == "0" { // User not register
                        
                        if let infoRing = _info.last {
                            self.phoneTextField.stringValue = infoRing.to
                        }
                      
                    } else { // User regestered
                        self.nameTextField.stringValue = userInfo.name
                        self.phoneTextField.stringValue = userInfo.phone
                        self.companyTextField.stringValue = userInfo.parentName
                        self.indexTypePhone = Int(userInfo.phoneType.stringByReplacingOccurrencesOfString(":", withString: "")) ?? 0
                        
                        self.customerDict = CRMCallHelpers.createDictionaryCustomer(withData: userInfo)
                        
                        var productNames = [String]()
                        for product in userInfo.products {
                            productNames.append(product.name)
                            self.productCodeOfCustomer.append(product.code)
                        }
                        self.productTextField.stringValue = productNames.joinWithSeparator(",")
                        

                        
                        var staffNameList = [String]()
                        for staff in userInfo.staffs {
                            staffNameList.append(staff.name)
                        }
                        self.assignedTextFeild.stringValue = staffNameList.joinWithSeparator(",")
                        
                        let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
                        
                        self.staffDict = CRMCallHelpers.createDictionaryStaff(withData: userInfo.staffs, phoneNumber: phoneSetting ?? "0")
                        
                        if self.nameTextField.stringValue != "" {
                            self.nameTextField.enabled = false
                            self.companyTextField.enabled = false
                        }
                    }
                    
                    
                    ///-------------- SEARCH API CUSTOMER IN CALL HISTORY-------------// // GET DATA FOR TABLE
                    let types = [CRMCallHelpers.TypeApi.Call.rawValue,
                        CRMCallHelpers.TypeApi.Meeting.rawValue,
                        CRMCallHelpers.TypeApi.Fax.rawValue,
                        CRMCallHelpers.TypeApi.Post.rawValue,
                        CRMCallHelpers.TypeApi.Appointment.rawValue,
                        CRMCallHelpers.TypeApi.Task.rawValue,
                        CRMCallHelpers.TypeApi.Sms.rawValue,
                        CRMCallHelpers.TypeApi.Email.rawValue
                    ]
                    let customerCode = ((self.customerDict[0]["customer_code"]) as? String) ?? ""
                    let urlHistory = CRMCallConfig.API.searchHistoryCallOfCustomer(withCompany: CRMCallManager.shareInstance.cn, customerCode: customerCode, limit: 21, offset: 0, sort: CRMCallHelpers.Sort.DateTime.rawValue, order: CRMCallHelpers.Order.Desc.rawValue, type: types)
                    
                    AlamofireManager.requestUrlByGET(withURL: urlHistory, parameter: nil) { (datas, success) in
                        if success {
                            println("-----------> Search history Call of customer data responce: \(datas)")
                            
                            guard let data = datas["rows"] as? [[String: AnyObject]] else {
                                println("Cannot get data after register employee success")
                                return
                            }
                            
                            self.dataHistoryDict = data
                            
                            self.historyTableView.reloadData()
                        } else {
                            println("---XXXXX---->>> Get Search history Call of customer data fail with message: \(datas)")
                        }
                    }

                })
            }
        })
    }
    
    func configItems() {
        
        self.title = "History Call"
        
        self.panelGeneral.wantsLayer = true
        self.panelDetail.wantsLayer = true
        
        panelGeneral.layer?.borderColor = NSColor.grayColor().CGColor
        panelGeneral.layer?.borderWidth = 1.0
        
        panelDetail.layer?.borderColor = NSColor.grayColor().CGColor
        panelDetail.layer?.borderWidth = 1.0
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init HistoryCallViewController Screen")
        
        initData()
        registerNotification()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        configItems()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        deregisterNotification()
        
        self.closeWindown()
    }
    
    private func closeWindown() {
        dispatch_async(dispatch_get_main_queue()) { 
            if let historyWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] {
                historyWindowController.close()
                CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.HistoryCallWindowController)
            }
        }
    }
    
    // MARK: - Notification
    func registerNotification() {
        handlerNotificationByeEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.ByeEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.timer.cancel()
        })
        
        handlerNotificationInviteResultEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.InviteResultEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            dispatch_async(dispatch_get_main_queue(), {
                if CRMCallManager.shareInstance.myCurrentDirection == .InBound {
                   
                } else if CRMCallManager.shareInstance.myCurrentDirection == .OutBound {
                   self.timer.start(true)
                }
            })
        })
        
        handlerNotificationCancelEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.CancelEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.timer.cancel()
            })
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationByeEvent)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationInviteResultEvent)
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationCancelEvent)
    }
    
    // MARK: - Handling event
    
    @IBAction func actionShowHistory(sender: AnyObject) {
        
        println("--> index \(self.phoneTypePopUpBtn.indexOfSelectedItem)")
        println("--> title \(CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.objectValueOfSelectedItem! as! String, dictionary: self.addressDict))")
    }
    
    @IBAction func actionSave(sender: AnyObject) {
        
        if self.phoneTextField.stringValue == "" {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Please input phone number", dismissText: "Cancel", completion: { result in })
            return
        }
        
        self.uploadCallHistory()
        
        if isUnRegister {
            return
        }
        
        if self.customerSelect.count != 0 {
            
            if customerSelect["type"] as! String == CRMCallHelpers.TypeApi.Employee.rawValue {
                self.registerPhoneForEmployee()
            }
            
            if customerSelect["type"] as! String == CRMCallHelpers.TypeApi.Company.rawValue {
                
                let value = self.phoneTypePopUpBtn.stringValue
                if let _ = CRMCallHelpers.findKeyForValue(value, dictionary: self.addressDict) {
                    if self.nameTextField.stringValue != "" {
                        self.registerEmployee()
                    } else {
                        self.registerPhoneForCompany()
                    }
                } else {
                    self.registerPhoneForCompanyLabel()
                }// Manually input
            }
            
            if customerSelect["type"] as! String == CRMCallHelpers.TypeApi.Contact.rawValue {
                self.registerPhoneForContact()
            }
        } else {
            println("Not found data customer from Customer List")
            self.closeWindown()
        }
        
        //self.getUploadCallHistory()
    }
    
    @IBAction func actionAddTask(sender: AnyObject) {
    }
    
    @IBAction func actionCreateTicket(sender: AnyObject) {
    }
    
    @IBAction func actionShowPurpose(sender: AnyObject) {
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)!
        
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxX
        
        let viewController = popover.contentViewController as! PopUpViewController
        viewController.dataDict = purposeDict
        viewController.identifier = purposeID
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView as! NSButton, preferredEdge: preferredEdge)
    }
    
    @IBAction func actionShowSubject(sender: AnyObject) {
        
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)!
        
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxX
        
        let viewController = popover.contentViewController as! PopUpViewController
        
        viewController.dataDict = self.setSelectedForDict(withData: productDict, values: self.productCodeOfCustomer)
        viewController.identifier = subjectID
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView as! NSButton, preferredEdge: preferredEdge)
    }
    
    @IBAction func actionCustomerListShow(sender: AnyObject) {
        
        self.nameTextField.enabled = true
        self.companyTextField.enabled = true
        self.nameTextField.stringValue = ""
        self.companyTextField.stringValue = ""
        
        if let customersViewController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
            customersViewController.showWindow(nil)
        } else {
            let customersViewController = CustomerListWindowController.createInstance()
            let customerView = customersViewController.contentViewController as! CustomerListViewController
            customerView.keySearchTextFeild.stringValue = self.phoneTextField.stringValue
            customerView.delegate = self
            
            customersViewController.showWindow(nil)
            customerView.searchCustomer()
            CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] = customersViewController
        }
    }
    
    // MARK: - Other func
    private func buildDictionary(withValue value: [[String: String]], isPurpose: Bool) -> [NSMutableDictionary] {
        var result = [NSMutableDictionary]()
        
        if isPurpose {
            for item in value {
                let key = item["id"]
                let value = item["content"]
                
                let dic = NSMutableDictionary()
                dic["id"] = key!
                dic["NameID"] = value
                dic["CheckID"] = 0
                
                result.append(dic)
            }
        } else {
            for item in value {
                let is_discontinue = item["is_discontinue"]
                let name = item["name"]
                let prod_code = item["prod_code"]
                let product_id = item["product_id"]
                
                let dic = NSMutableDictionary()
                dic["id"] = product_id!
                dic["NameID"] = name
                dic["CheckID"] = 0
                dic["prod_code"] = prod_code
                dic["is_discontinue"] = is_discontinue
                
                result.append(dic)
            }
        }
        
        return result
    }
    
    private func getStringValueInDict(withValues values: [NSMutableDictionary]) -> String {
        var result = ""
        var strList = [String]()
        
        for item in values {
            let isCheck = item["CheckID"] as! Int
            if isCheck == 1 {
                let valueStr = item["NameID"] as! String
                strList.append(valueStr)
            }
        }
        
        result = strList.joinWithSeparator(";")
        
        return result
    }
    
    private func setSelectedForDict(withData data: [NSMutableDictionary], values: [String]) -> [NSMutableDictionary] {
        
        for item in data {
            for value in values {
                if value == item["id"] as! String {
                    item["CheckID"] = 1
                }
            }
        }
        
        return data
    }
    
    private func uploadCallHistory() {
        
        let url = CRMCallConfig.API.uploadCallHistory(withCompany: CRMCallManager.shareInstance.cn)
        
        let dateTimer = NSDate().stringFormattedAsRFC3339
        
        var priority = "1"
        if let p = CRMCallHelpers.findKeyForValue(self.priorityPopUpBtn.titleOfSelectedItem!, dictionary: self.priorityDict) {
            priority = p
        }
        
        let direction = "[Incoming]" == self.typeCallLabel.stringValue ? "in" : "out"
        
        let purposeDict = CRMCallHelpers.createDictionaryPurpose(withData: self.purposeDict)
        
        let parameter = RequestBuilder.saveDailyCall(withCN: CRMCallManager.shareInstance.cn,
                                                     groupCall: "", regdate: dateTimer, dateTime: dateTimer,
                                                     priority: Int(priority)!, duration: self.timer.count, direction: direction,
                                                     note: self.noteTextView.string ?? "", subject: self.subjectTextField.stringValue, customerDict: self.customerDict, staffDict: self.staffDict, purposeDict: purposeDict)

        println("url request : \n \(url)")
        println("paramater request : \n \(parameter)")
        
        AlamofireManager.requestUrlByPOST(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Upload data responce: \(datas)")
                
                guard let data = datas["rows"] as? [String: AnyObject] else {
                    println("Cannot get data after Upload history success")
                    return
                }
                
                println("-----> Upload history data: \(data)")
                if self.isUnRegister {
                    self.closeWindown()
                }
            } else {
                println("---XXXXX---->>> Upload call history data fail with message: \(datas)")
            }
        }
    }
    
    // MARK: ------------Register-----------
    private func registerEmployee() {
        
        let labelPhone = CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.objectValueOfSelectedItem! as! String, dictionary: self.addressDict) ?? "0"
            
            let info = CRMCallHelpers.createDictionaryEmployee(withData: [labelPhone], phoneNumber: [self.phoneTextField.stringValue])
            let parameter = RequestBuilder.registerEmployee(withName: self.nameTextField.stringValue, info: info)
            
            let url = CRMCallConfig.API.registerEmployee(withCompany: CRMCallManager.shareInstance.cn, companyCode: (customerSelect["code"] ?? "") as! String)
        
            println("url request : \n \(url)")
            println("paramater request : \n \(parameter)")
        
            AlamofireManager.requestUrlByPOST(withURL: url, parameter: parameter) { (datas, success) in
                if success {
                    println("-----------> Register employee data responce: \(datas)")
                    
                    //                guard let data = datas["rows"] as? [String: AnyObject] else {
                    //                    println("Cannot get data after register employee success")
                    //                    return
                    //                }
                } else {
                    println("---XXXXX---->>> Register employee data fail with message: \(datas)")
                }
                self.closeWindown()
            }
    }
    
    private func registerPhoneForCompanyLabel() {
        
        let labelPhone = "1"
        let labelValue = self.phoneTypePopUpBtn.stringValue
        
        let parameter = CRMCallHelpers.createDictionaryRegisterManually(withData: labelPhone, labelValue: labelValue, phoneNumber: self.phoneTextField.stringValue, cateID: "400", cn: CRMCallManager.shareInstance.cn)
        
        let url = CRMCallConfig.API.registerWithLabel(withCompany: CRMCallManager.shareInstance.cn, companyCode: (customerSelect["code"] ?? "") as! String)
        
        println("url request : \n \(url)")
        println("paramater request : \n \(parameter)")
        
        AlamofireManager.requestUrlByPUT(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Register employee data responce: \(datas)")
                
                //                guard let data = datas["rows"] as? [String: AnyObject] else {
                //                    println("Cannot get data after register employee success")
                //                    return
                //                }
                self.closeWindown()
            } else {
                println("---XXXXX---->>> Register employee data fail with message: \(datas)")
            }
        }
    }
    
    private func registerPhoneForCompany() {
        let labelPhone = CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.objectValueOfSelectedItem! as! String, dictionary: self.addressDict) ?? "0"
        
        let parameter = CRMCallHelpers.createDictionaryTelephoneOfSomeOne(withData: labelPhone, phoneNumber: self.phoneTextField.stringValue, cateID: "400", cn: CRMCallManager.shareInstance.cn)
        
        let url = CRMCallConfig.API.registerTelephoneOfCompany(withCompany: CRMCallManager.shareInstance.cn, companyCode: (customerSelect["code"] ?? "") as! String)
        
        AlamofireManager.requestUrlByPUT(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Register telephone of company data responce: \(datas)")
                
                //                guard let data = datas["rows"] as? [String: AnyObject] else {
                //                    println("Cannot get data after register employee success")
                //                    return
                //                }
                self.closeWindown()
            } else {
                println("---XXXXX---->>> Register telephone of company data fail with message: \(datas)")
            }
        }
    }
    
    private func registerPhoneForEmployee() {
        
        let labelPhone = CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.objectValueOfSelectedItem! as! String, dictionary: self.addressDict) ?? "0"
        
        let parameter = CRMCallHelpers.createDictionaryTelephoneOfSomeOne(withData: labelPhone, phoneNumber: self.phoneTextField.stringValue, cateID: "400", cn: CRMCallManager.shareInstance.cn)
        
        let url = CRMCallConfig.API.registerTelephoneForEmployee(withCompany: CRMCallManager.shareInstance.cn, employeeCode: (customerSelect["code"] ?? "") as! String)
        
        AlamofireManager.requestUrlByPUT(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Register telephone of employee data responce: \(datas)")
                
                //                guard let data = datas["rows"] as? [String: AnyObject] else {
                //                    println("Cannot get data after register employee success")
                //                    return
                //                }
                self.closeWindown()
            } else {
                println("---XXXXX---->>> Register telephone of employee data fail with message: \(datas)")
            }
        }
    }
    
    private func registerPhoneForContact() {
        
        let labelPhone = CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.objectValueOfSelectedItem! as! String, dictionary: self.addressDict) ?? "0"
        
        let parameter = CRMCallHelpers.createDictionaryTelephoneOfSomeOne(withData: labelPhone, phoneNumber: self.phoneTextField.stringValue, cateID: "400", cn: "")
        
        let url = CRMCallConfig.API.registerTelephoneForEmployee(withCompany: CRMCallManager.shareInstance.cn, employeeCode: (customerSelect["code"] ?? "") as! String)
        
        AlamofireManager.requestUrlByPUT(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Register telephone of contact data responce: \(datas)")
                
                //                guard let data = datas["rows"] as? [String: AnyObject] else {
                //                    println("Cannot get data after register employee success")
                //                    return
                //                }
                self.closeWindown()
            } else {
                println("---XXXXX---->>> Register telephone of contact data fail with message: \(datas)")
            }
        }
    }
    
    private func getUploadCallHistory() {
        
        let parameter = RequestBuilder.cookies()
        let url = CRMCallConfig.API.getUploadCallHistory(withCompany: "1", id: "06385adb-4d22-4bb7-8c79-f9489890aadc")
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> HISTORY DATA CALL RESPONCE: \(datas)")
                
                if let data = datas["rows"] as? [String: AnyObject] {
                    println("HISTORY DATA CALL GET FROM SERVER ----> \(data)")
                } else {
                    println("Not found HISTORY CALL from server")
                }
                
                
            } else {
                println("---XXXXX---->>> GET DATA HISTORY CALL FAIL WITH MESSAGE: \(datas)")
            }
        }
    }
}

// MARK: - Table Delegate

extension HistoryCallViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataHistoryDict.count ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let object = dataHistoryDict[row]
        
        if tableColumn?.identifier == "dateID" {
            let date = object["regdate"] as! String
            let dateStr = NSDate(RFC3339FormattedString: date)
            return dateStr?.stringFormattedDateTime
            
        } else if tableColumn?.identifier == "subjectID" {
            return object["subject"] as! String
        } else {
            
            if let staffs = object["staff"] as? [[String: AnyObject]] {
                for staff in staffs {
                    return staff["staff_name"] as! String
                }
            }
            return ""
        }
    }
}

// MARK: - Popover Delegate

extension HistoryCallViewController: NSPopoverDelegate {
    
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
    
    func popoverDidShow(notification: NSNotification) {
        println("click show")
    }
    
    func popoverDidClose(notification: NSNotification) {
        let closeReason = notification.userInfo![NSPopoverCloseReasonKey] as! String
        if (closeReason == NSPopoverCloseReasonStandard) {
            println("click close")
            let viewController = self.popover.contentViewController as! PopUpViewController
            println("value --> \(viewController.dataDict)")
            
            if viewController.identifier == purposeID {
                self.purposeDict = viewController.dataDict
                self.purposeTextField.stringValue = self.getStringValueInDict(withValues: self.purposeDict)
            } else {
                self.productDict = viewController.dataDict
                self.productTextField.stringValue = self.getStringValueInDict(withValues: self.productDict)
            }
        }
    }
}

// MARK: - CustomersList delegate
extension HistoryCallViewController: CustomerListDelegate {
    
    func chooseCustomer(withDict dict: [String: AnyObject]?) {
        if let d = dict {
            
            self.isUnRegister = false
            
            println("Data select \(d)")
            customerSelect = d
            
            if d["type"] as! String == CRMCallHelpers.TypeApi.Employee.rawValue {
                if let name = d["name"] as? String {
                    self.nameTextField.stringValue = name
                }
                
                if let name = d["company"] as? String {
                    self.companyTextField.stringValue = name
                }
                
                self.nameTextField.enabled = false
                self.companyTextField.enabled = false
            }
            
            if d["type"] as! String == CRMCallHelpers.TypeApi.Company.rawValue {
                if let name = d["name"] as? String {
                    self.companyTextField.stringValue = name
                }
                self.companyTextField.enabled = false
            }
            
            if d["type"] as! String == CRMCallHelpers.TypeApi.Contact.rawValue {
                if let name = d["name"] as? String {
                    self.nameTextField.stringValue = name
                }
                
                if let name = d["company"] as? String {
                    self.companyTextField.stringValue = name
                }
                self.nameTextField.enabled = false
                self.companyTextField.enabled = false
            }
            
        } else {
            self.isUnRegister = true
            self.nameTextField.enabled = true
            self.companyTextField.enabled = true
        }
    }
}
