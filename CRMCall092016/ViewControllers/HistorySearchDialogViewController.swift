//
//  HistorySearchDialogViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 11/3/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class HistorySearchDialogViewController: NSViewController, ViewControllerProtocol {

    // MARK: - Properties
    @IBOutlet weak var tableViewHistory: NSTableView!
    @IBOutlet weak var dateView: NSView!
    @IBOutlet weak var customerView: NSView!
    @IBOutlet weak var historyView: NSView!
    @IBOutlet weak var staffView: NSView!
    @IBOutlet weak var priorityView: NSView!
    
    @IBOutlet weak var startDay: NSDatePicker!
    @IBOutlet weak var endDay: NSDatePicker!
    
    @IBOutlet weak var customerNameTextField: NSTextField!
    @IBOutlet weak var customerPhoneTextField: NSTextField!
    @IBOutlet weak var customerComnanyTextField: NSTextField!
    @IBOutlet weak var customerCodeTextField: NSTextField!
    
    @IBOutlet weak var historyTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    
    @IBOutlet weak var staffNameTextField: NSTextField!
    @IBOutlet weak var staffExtTextField: NSTextField!
    
    @IBOutlet weak var priorityPopUpButton: NSPopUpButton!
    @IBOutlet weak var activityPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var progressSearch: NSProgressIndicator!
    
    private var dataHistoryDict = [[String : AnyObject]]()
    
    private var priorityDict = ["":""]
    private var activityDict = ["":""]
    
    private var offset = 0
    private var limit = 30
    private var total = 0
    private var indexScroll = 0
    private var isReplaceSearch = true
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("HistorySearchDialogViewControllerID") as! HistorySearchDialogViewController
    }
    
    func initData() {
        
        priorityDict = [CRMCallHelpers.Priority.All.rawValue:"All",
                        CRMCallHelpers.Priority.VeryLow.rawValue:"Very Low",
                        CRMCallHelpers.Priority.Low.rawValue:"Low",
                        CRMCallHelpers.Priority.Normal.rawValue:"Normal",
                        CRMCallHelpers.Priority.Hight.rawValue:"Hight",
                        CRMCallHelpers.Priority.VeryHight.rawValue:"Very Hight"]
        
        var values = Array(priorityDict.values)
        values = values.sort()
        priorityPopUpButton.addItemsWithTitles(values)
        
        activityDict = [CRMCallHelpers.TypeApi.All.rawValue:"All",
                        CRMCallHelpers.TypeApi.Meeting.rawValue:"Meeting",
                        CRMCallHelpers.TypeApi.Fax.rawValue:"Fax",
                        CRMCallHelpers.TypeApi.Post.rawValue:"Post",
                        CRMCallHelpers.TypeApi.Email.rawValue:"Email",
                        CRMCallHelpers.TypeApi.Appointment.rawValue:"Appointment",
                        CRMCallHelpers.TypeApi.Task.rawValue:"Task",
                        CRMCallHelpers.TypeApi.Call.rawValue:"Call",
                        CRMCallHelpers.TypeApi.Sms.rawValue:"Sms"]
        
        var valuesAc = Array(activityDict.values)
        valuesAc = valuesAc.sort()
        activityPopUpButton.addItemsWithTitles(valuesAc)
        
        startDay.dateValue = NSDate()
        endDay.dateValue = NSDate()
        
        //actionSearch("")
    }
    
    func configItems() {
        dateView.wantsLayer = true
        customerView.wantsLayer = true
        historyView.wantsLayer = true
        priorityView.wantsLayer = true
        staffView.wantsLayer = true
        
        dateView.layer?.borderColor = NSColor.grayColor().CGColor
        dateView.layer?.borderWidth = 1.0
        
        customerView.layer?.borderColor = NSColor.grayColor().CGColor
        customerView.layer?.borderWidth = 1.0
        
        historyView.layer?.borderColor = NSColor.grayColor().CGColor
        historyView.layer?.borderWidth = 1.0

        priorityView.layer?.borderColor = NSColor.grayColor().CGColor
        priorityView.layer?.borderWidth = 1.0

        staffView.layer?.borderColor = NSColor.grayColor().CGColor
        staffView.layer?.borderWidth = 1.0
        
        enableControl(true)
        
        let clipView = self.tableViewHistory.enclosingScrollView!.contentView
        NSNotificationCenter.defaultCenter().addObserver(self,selector:#selector(CustomerListViewController.myBoundsChangeNotificationHandler(_:)),
                                                         name:NSViewBoundsDidChangeNotification,
                                                         object:clipView);
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init screen HistorySearchDialogViewController")
        
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.title = "History Search"
        
        configItems()
        
        actionSearch("")
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        if priorityPopUpButton != nil {
            priorityPopUpButton.removeFromSuperview()
            priorityPopUpButton = nil
        }
        
        if activityPopUpButton != nil {
            activityPopUpButton.removeFromSuperview()
            activityPopUpButton = nil
        }
        
        self.closeWindow()
    }
    
    private func closeWindow() {
        CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.HistorySearchDialogViewController)
    }
    
    // MARK: - Handling event
    @IBAction func actionSearch(sender: AnyObject) {
        
        if !CRMCallManager.shareInstance.isInternetConnect {
            if let w = self.view.window {
                CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please check connect internet.", dismissText: "Ok", completion: { result in })
            }
            return
        }
        
        if customerPhoneTextField.stringValue != "" {
            guard let _ = Int(customerPhoneTextField.stringValue) else {
                if let w = self.view.window {
                    CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please input number at phone.", dismissText: "Ok", completion: { result in })
                }
                return
            }
        }
        
        offset = 0
        limit = 30
        indexScroll = 0
        isReplaceSearch = true
        search()
    }
    
    func search() {
        enableControl(false)

        let types = selectActivity()
        
        var priority = "1"
        if let p = CRMCallHelpers.findKeyForValue(self.priorityPopUpButton.titleOfSelectedItem!, dictionary: self.priorityDict) {
            priority = p
        }
        
        let since = startDay.dateValue.stringFormattedAsRFC3339
        let until = endDay.dateValue.stringFormattedAsRFC3339
        
        let urlHistoryCall = CRMCallConfig.API.searchHistoryCall(withCompany: CRMCallManager.shareInstance.cn,       customerName: customerNameTextField.stringValue,
            customerPhone: customerPhoneTextField.stringValue,
                                                                 subject: historyTextField.stringValue,
                                                                 content: notesTextField.stringValue,
                                                                 staffNo: staffExtTextField.stringValue,
                                                                 staffName: staffNameTextField.stringValue, parentName: customerComnanyTextField.stringValue,
                                                                 customerCode: customerCodeTextField.stringValue, priority: priority,
                                                                 since: since, until: until, limit: limit,
                                                                 offset: offset, sort: CRMCallHelpers.Sort.DateTime.rawValue,
                                                                 order: CRMCallHelpers.Order.Desc.rawValue,
                                                                 type: types)
        
        AlamofireManager.requestUrlByGET(withURL: urlHistoryCall, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Search history Call responce <------------ \n \(datas)")
                
                if self.isReplaceSearch {
                    self.dataHistoryDict.removeAll()
                }
                
                if let attrs = datas["attr"] as? [String: AnyObject] {
                    
                    if let _totalPage = attrs["total"] as? Int {
                        self.total = _totalPage
                    }
                }
                
                guard let data = datas["rows"] as? [[String: AnyObject]] else {
                    println("Cannot get data after register employee success")
                    self.enableControl(true)
                    return
                }
                
                if self.isReplaceSearch {
                    self.dataHistoryDict = data
                } else {
                    self.dataHistoryDict.appendContentsOf(data)
                }
                
                self.isReplaceSearch = true
                self.tableViewHistory.reloadData()
                self.enableControl(true)
            } else {
                self.enableControl(true)
                println("---XXXXX---->>> Get Search history Call fail with message: \(datas)")
            }
        }
    }
    
    // MARK: - Other func
    
    func myBoundsChangeNotificationHandler(withNotification :NSNotification) {
        let range = getVisibleRow()
        let local = range.location + range.length
        
        if isReplaceSearch && local == dataHistoryDict.count && indexScroll <= local && total > offset {
            
            indexScroll = local
            isReplaceSearch = false
            offset += limit

            search()
        }
    }
    
    func getVisibleRow() -> NSRange {
        if let scrollView = self.tableViewHistory.enclosingScrollView {
            let visibleRect = scrollView.contentView.visibleRect
            let range = self.tableViewHistory.rowsInRect(visibleRect)
            return range
        }
        return NSRange()
    }
    
    private func selectActivity() -> Array<String> {
        var types = [""]
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.All.rawValue {
            types = [CRMCallHelpers.TypeApi.Call.rawValue,
                     CRMCallHelpers.TypeApi.Meeting.rawValue,
                     CRMCallHelpers.TypeApi.Fax.rawValue,
                     CRMCallHelpers.TypeApi.Post.rawValue,
                     CRMCallHelpers.TypeApi.Appointment.rawValue,
                     CRMCallHelpers.TypeApi.Task.rawValue,
                     CRMCallHelpers.TypeApi.Sms.rawValue,
                     CRMCallHelpers.TypeApi.Email.rawValue
            ]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Call.rawValue {
            types = [CRMCallHelpers.TypeApi.Call.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Meeting.rawValue {
            types = [CRMCallHelpers.TypeApi.Meeting.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Fax.rawValue {
            types = [CRMCallHelpers.TypeApi.Fax.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Post.rawValue {
            types = [CRMCallHelpers.TypeApi.Post.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Appointment.rawValue {
            types = [CRMCallHelpers.TypeApi.Appointment.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Task.rawValue {
            types = [CRMCallHelpers.TypeApi.Task.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Sms.rawValue {
            types = [CRMCallHelpers.TypeApi.Sms.rawValue]
        }
        
        if activityPopUpButton.titleOfSelectedItem?.lowercaseString == CRMCallHelpers.TypeApi.Email.rawValue {
            types = [CRMCallHelpers.TypeApi.Email.rawValue]
        }
        
        return types
    }
    
    private func enableControl(state: Bool) {
        
        startDay.enabled = state
        endDay.enabled = state
        
        _ = customerNameTextField.stringValue
        _ = customerPhoneTextField.stringValue
        _ = customerComnanyTextField.stringValue
        _ = customerCodeTextField.stringValue
        _ = historyTextField.stringValue
        _ = notesTextField.stringValue
        _ = staffNameTextField.stringValue
        _ = staffExtTextField.stringValue
        
        customerNameTextField.enabled = state
        customerPhoneTextField.enabled = state
        customerComnanyTextField.enabled = state
        customerCodeTextField.enabled = state
        
        historyTextField.enabled = state
        notesTextField.enabled = state
        
        staffNameTextField.enabled = state
        staffExtTextField.enabled = state
        
        priorityPopUpButton.enabled = state
        activityPopUpButton.enabled = state
        
        searchButton.enabled = state
        
        progressEnable(state)
    }
    
    private func progressEnable(state: Bool) {
        if state {
            progressSearch.stopAnimation(state)
            progressSearch.hidden = state
        } else {
            progressSearch.startAnimation(!state)
            progressSearch.hidden = state
        }
    }
}

// MARK - TableViewDelegate and TableViewDataSource

extension HistorySearchDialogViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataHistoryDict.count ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let object = dataHistoryDict[row]
        
        if tableColumn?.identifier == "DateID" {
            let date = object["date_time"] as? String ?? ""
            let dateStr = NSDate(RFC3339FormattedString: date)
            return dateStr?.stringFormattedDateTime
            
        } else if tableColumn?.identifier == "NameID" {
            if let customers = object["customer"] as? [[String: AnyObject]] {
                for customer in customers {
                    var name = ""
                    let cusName = customer["customer_name"] as? String ?? ""
                    let phone = customer["customer_phone"] as? String ?? ""
                    name = "\(cusName) (\(phone))"
                    return name
                }
            }
            return ""
        } else if tableColumn?.identifier == "ActivityID" {
            return object["type"] as? String ?? ""
        } else if tableColumn?.identifier == "StaffID" {
            if let staffs = object["staff"] as? [[String: AnyObject]] {
                for staff in staffs {
                    return staff["staff_name"] as? String ?? ""
                }
            }
            return ""
        } else if tableColumn?.identifier == "SubjectID" {
           return object["subject"] as? String ?? ""
        } else {
            
            if let customers = object["customer"] as? [[String: AnyObject]] {
                for customer in customers {
                    return customer["parent_name"] as? String ?? ""
                }
            }
            return ""
        }
    }
}
