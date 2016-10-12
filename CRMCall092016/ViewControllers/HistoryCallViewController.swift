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
    
    private var purposeList: [[String: String]] = [[String: String]]()
    private var productList: [[String: String]] = [[String: String]]()
    
    private var purposeDict = [NSMutableDictionary]()
    private var productDict = [NSMutableDictionary]()
    
    private var dataHistoryDict = [[String : AnyObject]]()
    
    private var idCallGroup = ""
    
    private var timer: DispatchTimer!
    
    private var staffDict = [[String : AnyObject]]()
    private var customerDict = [[String : AnyObject]]()
    
    private var customerSelect = [String : AnyObject]()
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        var popUpViewController = PopUpViewController(nibName: "PopUpViewController", bundle: nil)
        popover.contentViewController = popUpViewController
        popover.delegate = self
        return popover
    }()
    
    private var handlerNotificationByeEvent: AnyObject!
    
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
        timer.start(true)
        
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
        
        Cache.shareInstance.getRingInfo({ info in
            
            guard let _info = info else {
                println("======> RingIng Info: NULL")
                self.phoneTextField.stringValue = "0"
                return
            }
            self.phoneTextField.stringValue = (_info.last?.from)!
            
            if let idCall = (_info.last?.callID) {
                
                Cache.shareInstance.getCustomerInfo(with:  NSPredicate(format: "idx = %@", "0_2897483473@192.168.4.2"), Result: { userInfo in
                    
                    guard let userInfo = userInfo?.first else {
                        println("Not found Info CallID of \(_info.last?.from) and CallID: \(idCall)")
                        self.nameTextField.stringValue = ""
                        return
                    }
                    self.nameTextField.stringValue = "" //userInfo.name
                    self.idCallGroup = userInfo.idx
                    self.customerDict = CRMCallHelpers.createDictionaryCustomer(withData: userInfo)
                    
                    //                    let demoProduct = [
                    //                        Product(value: ["idx":"1", "cn":"1", "name":"vinh", "code":"1234"]),
                    //                        Product(value: ["idx":"2", "cn":"2", "name":"vinh1", "code":"1235"]),
                    //                        Product(value: ["idx":"3", "cn":"3", "name":"vinh2", "code":"1236"]),
                    //                        Product(value: ["idx":"5", "cn":"5", "name":"vinh4", "code":"1238"]),
                    //                        Product(value: ["idx":"6", "cn":"3", "name":"vinh2", "code":"1236"]),
                    //                        Product(value: ["idx":"7", "cn":"3", "name":"vinh2", "code":"1236"]),
                    //                        Product(value: ["idx":"8", "cn":"3", "name":"vinh2", "code":"1236"]),
                    //                        Product(value: ["idx":"9", "cn":"3", "name":"vinh2", "code":"1236"]),
                    //                        Product(value: ["idx":"10", "cn":"3", "name":"vinh2", "code":"1236"]),
                    //                        Product(value: ["idx":"11", "cn":"3", "name":"vinh2", "code":"1236"])
                    //                    ]
                    
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
                    
                    var staffNameList = [String]()
                    for staff in demoStaff {
                        staffNameList.append(staff.name)
                    }
                    let staffLst = staffNameList.joinWithSeparator(",")
                    
                    let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
                    
                    self.staffDict = CRMCallHelpers.createDictionaryStaff(withData: demoStaff, phoneNumber: phoneSetting ?? "0")
                    
                    self.assignedTextFeild.stringValue = staffLst
                    
                    if self.nameTextField.stringValue != "" {
                        self.nameTextField.enabled = false
                        self.companyTextField.enabled = false
                    }
                    
                    ///-------------- SEARCH API CUSTOMER IN CALL HISTORY-------------// // GET DATA FOR TABLE
                    let types6 = [CRMCallHelpers.TypeApi.Call.rawValue,
                        CRMCallHelpers.TypeApi.Meeting.rawValue,
                        CRMCallHelpers.TypeApi.Fax.rawValue,
                        CRMCallHelpers.TypeApi.Post.rawValue,
                        CRMCallHelpers.TypeApi.Appointment.rawValue,
                        CRMCallHelpers.TypeApi.Task.rawValue,
                        CRMCallHelpers.TypeApi.Sms.rawValue,
                        CRMCallHelpers.TypeApi.Email.rawValue
                    ]
                    let url6 = CRMCallConfig.API.searchHistoryCallOfCustomer(withCompany: CRMCallManager.shareInstance.cn, customerCode: "CONT-6484-00013", limit: 21, offset: 0, sort: CRMCallHelpers.Sort.DateTime.rawValue, order: CRMCallHelpers.Order.Desc.rawValue, type: types6)
                    
                    AlamofireManager.requestUrlByGET(withURL: url6, parameter: nil) { (datas, success) in
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
                    self.phoneTypePopUpBtn.selectItemAtIndex(0)
                    
                } else {
                    println("Not found address from server")
                }
                
            } else {
                println("---XXXXX---->>> Get data type phone fail with message: \(datas)")
            }
        }
        
        // GET PURPOSE LIST
        url = CRMCallConfig.API.purposeList(withCNKey: "102")
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                if let data = datas["rows"] as? [[String: String]] {
                    self.purposeList = data
                    self.purposeDict = self.buildDictionary(withValue: self.purposeList, isPurpose: true)
                } else {
                    println("Not found purpose list from server")
                }
                
                println("Purpose data: \(self.purposeList)")
            } else {
                println("---XXXXX---->>> Get purpose data fail with message: \(datas)")
            }
        }
        
        // GET PRODUCT LIST
        url = CRMCallConfig.API.productList(withCNKey: "102")
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Product data responce: \(datas)")
                
                if let data = datas["rows"] as? [[String: String]] {
                    self.productList = data
                    self.productDict = self.buildDictionary(withValue: self.productList, isPurpose: false)
                } else {
                    println("Not found product list from server")
                }
                
                println("Product data:  \(self.productList)")
            } else {
                println("---XXXXX---->>> get product data fail with messgae: \(datas)")
            }
        }
        
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
        
        if let historyWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.HistoryCallWindowController] {
            historyWindowController.close()
            CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.HistoryCallWindowController)
        }

    }
    
    // MARK: - Notification
    func registerNotification() {
        handlerNotificationByeEvent = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.ByeEvent, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.timer.cancel()
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationByeEvent)
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
        
        if !self.nameTextField.enabled {
            return
        }
        
        if self.customerSelect.count != 0 {
            
            if customerSelect["type"] as! String == CRMCallHelpers.TypeApi.Employee.rawValue {
                self.registerPhoneForEmployee()
            }
            
            if customerSelect["type"] as! String == CRMCallHelpers.TypeApi.Company.rawValue {
                if self.nameTextField.stringValue != "" {
                    self.registerEmployee()
                } else {
                    self.registerPhoneForCompany()
                }
            }
            
            if customerSelect["type"] as! String == CRMCallHelpers.TypeApi.Contact.rawValue {
                self.registerPhoneForContact()
            }
        } else {
            println("Not found data customer from Customer List")
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
        viewController.dataDict = productDict
        viewController.identifier = subjectID
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView as! NSButton, preferredEdge: preferredEdge)
    }
    
    @IBAction func actionCustomerListShow(sender: AnyObject) {
        
        self.nameTextField.enabled = true
        self.companyTextField.enabled = true
        
        if let customersViewController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
            customersViewController.showWindow(nil)
        } else {
            let customersViewController = CustomerListWindowController.createInstance()
            let customerView = customersViewController.contentViewController as! CustomerListViewController
            
            customerView.delegate = self
            
            customersViewController.showWindow(nil)
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
                                                     groupCall: self.idCallGroup, regdate: dateTimer, dateTime: dateTimer,
                                                     priority: Int(priority)!, duration: self.timer.count, direction: direction,
                                                     note: self.noteTextView.string ?? "", subject: self.subjectTextField.stringValue, customerDict: self.customerDict, staffDict: [[String : AnyObject]](), purposeDict: purposeDict)
        
//        let parameter = RequestBuilder.saveDailyCall(withCN: CRMCallManager.shareInstance.cn,
//                                                     groupCall: self.idCallGroup, regdate: dateTimer, dateTime: dateTimer,
//                                                     priority: Int(priority)!, duration: self.timer.count, direction: direction,
//                                                     note: self.noteTextView.string ?? "", subject: self.subjectTextField.stringValue, customerDict: self.customerDict, staffDict: self.staffDict, purposeDict: purposeDict)
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
            self.nameTextField.enabled = true
            self.companyTextField.enabled = true
        }
    }
}
