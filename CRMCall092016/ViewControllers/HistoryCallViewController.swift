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
    @IBOutlet weak var phoneTypePopUpBtn: NSPopUpButton!
    @IBOutlet weak var customButton: NSButton!
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
    
    private var dataHistoryDict = [NSMutableDictionary]()
    
    private var idCallGroup = ""
    
    private var timer: DispatchTimer!
    
    private var staffDict = [[String : AnyObject]]()
    private var customerDict = [[String : AnyObject]]()
    
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
                        self.nameTextField.stringValue = "No Name"
                        return
                    }
                    self.nameTextField.stringValue = userInfo.name
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
                })
            }
        })
        
        // GET TYPE PHONE
        var url = CRMCallConfig.API.phoneType()
        let parameter = RequestBuilder.cookies()
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("----------->Type phone data responce: \(datas)")
                
                if let address = datas["address"] as? [String: String] {
                    self.addressDict = address
                    
                    let arrString = Array(address.values)
                    self.phoneTypePopUpBtn.addItemsWithTitles(arrString)

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
        println("--> title \(CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.titleOfSelectedItem!, dictionary: self.addressDict))")
    }
    
    @IBAction func actionSave(sender: AnyObject) {
        
        self.uploadCallHistory()
        
        self.getUploadCallHistory()

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
            } else {
                println("---XXXXX---->>> Upload call history data fail with message: \(datas)")
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
        
        let object = dataHistoryDict[row] as NSMutableDictionary
        
        if tableColumn?.identifier == "dateID" {
            return object[(tableColumn?.identifier)!] as! String
        } else if tableColumn?.identifier == "subjectID" {
            return object[(tableColumn?.identifier)!] as! String
        } else {
           return object[(tableColumn?.identifier)!] as! String
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        dataHistoryDict[row].setObject(object!, forKey: (tableColumn?.identifier)!)
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
