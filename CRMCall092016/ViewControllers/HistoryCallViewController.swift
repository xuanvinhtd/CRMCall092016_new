//
//  HistoryCallViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/30/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

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
    @IBOutlet var NoteTextView: NSTextView!
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
    
    private var purposeID = "purposeID"
    private var subjectID = "SubjectID"
    
    private var addressDict = ["":""]
    private var purposeList: [[String: String]] = [[String: String]]()
    private var productList: [[String: String]] = [[String: String]]()
    
    private var purposeDict = [NSMutableDictionary]()
    private var productDict = [NSMutableDictionary]()
    
    private var dataHistoryDict = [NSMutableDictionary]()
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        var popUpViewController = PopUpViewController(nibName: "PopUpViewController", bundle: nil)
        popover.contentViewController = popUpViewController
        popover.delegate = self
        return popover
    }()

    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("HistoryCallViewControllerID") as! HistoryCallViewController
    }
    
    func initData() {
        
        // GET TYPE PHONE
        var url = CRMCallConfig.API.phoneType()
        let parameter = RequestBuilder.cookies()
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
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
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
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
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
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
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        configItems()
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
        
        let url = CRMCallConfig.API.uploadCallHistory(withCompany: "1")
        
        let customerDict = [[String : AnyObject]]()
        let purposeDict = [[String : AnyObject]]()
        let staffDict = [[String : AnyObject]]()
        
        let dateNow = ""
        
        let parameter = RequestBuilder.saveDailyCall(withCN: CRMCallManager.shareInstance.cn, groupCall: "663c0eea35e0873e39b5758a60f759a2@211.172.242.34", regdate: "2016-09-28T17:17:09+9", dateTime: "2016-09-28T17:17:09+9", priority: 1, duration: 3, direction: "in", note: "vinh note", subject: "vinh subject", customerDict: customerDict, staffDict: staffDict, purposeDict: purposeDict)
        
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
