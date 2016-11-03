//
//  CustomerListViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/11/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

protocol CustomerListDelegate: class {
    func chooseCustomer(withDict dict: [String: AnyObject]?)
}

class CustomerListViewController: NSViewController, ViewControllerProtocol {

    // MARK: - Properties
    weak var delegate: CustomerListDelegate?
    
    @IBOutlet weak var TypesPopUpbutton: NSPopUpButton!
    @IBOutlet weak var keySearchTextFeild: NSTextField!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var tableViewCustomers: NSTableView!
    @IBOutlet weak var unregisterButton: NSButton!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    private var dataDict = [[String: AnyObject]]()
    private var totalPage = 0
    private var currentPage = 0
    private var offset = 30
    private var indexScroll = 0
    private var isReplaceSearch = true
    
    private var itemSelect = [String: AnyObject]()
    
    var keySearchInit = ""
    var isCustomerListReviews = false
    
    private var handlerNotificationNotConnectInternet: AnyObject!
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("CustomerListViewControllerID") as! CustomerListViewController
    }
    
    func initData() {
        // Get type list
        let typesUI = [CRMCallHelpers.CustomerType.ALL.rawValue,
                     CRMCallHelpers.CustomerType.Company.rawValue,
                     CRMCallHelpers.CustomerType.Contact.rawValue,
                     CRMCallHelpers.CustomerType.Employee.rawValue]
        TypesPopUpbutton.addItemsWithTitles(typesUI)
        
        // Get customer list
        //searchCustomer()
    }

    func configItems() {
        
        let clipView = self.tableViewCustomers.enclosingScrollView!.contentView
        NSNotificationCenter.defaultCenter().addObserver(self,selector:#selector(CustomerListViewController.myBoundsChangeNotificationHandler(_:)),
        name:NSViewBoundsDidChangeNotification,
        object:clipView);
        
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotification()
        configItems()
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Customers List" 
        
        if isCustomerListReviews {
            unregisterButton.hidden = true
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        deregisterNotification()
        
        CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.CustomerListViewController)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSViewBoundsDidChangeNotification, object: nil)
    }
    
    // MARK: - Notification
    func registerNotification() {
        handlerNotificationNotConnectInternet = NSNotificationCenter.defaultCenter().addObserverForName(CRMCallConfig.Notification.NotConnetInternet, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            if !CRMCallManager.shareInstance.isInternetConnect {
                self.enableControl(true)
            }
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationNotConnectInternet)
    }
    
    // MARK: - Handing event
    
    @IBAction func actionSeach(sender: AnyObject) {
        isReplaceSearch = true
        currentPage = 0
        indexScroll = 0
        
        searchCustomer()
    }
    
    @IBAction func actionUnregisters(sender: AnyObject) {
        delegate?.chooseCustomer(withDict: nil)
        
        self.actionCannel("")
    }
    
    @IBAction func actionOK(sender: AnyObject) {
        
        if isCustomerListReviews {
            
            self.actionCannel("")
            return
        }
        
        for (_, index) in tableViewCustomers.selectedRowIndexes.enumerate() {
            itemSelect = dataDict[index]
        }
        
        if itemSelect.count == 0 {
            if let w = self.view.window {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please select customer", dismissText: "Ok", completion: { result in })
            }
            return
        }
        
        delegate?.chooseCustomer(withDict: itemSelect)
        
        self.actionCannel("")
    }
    
    @IBAction func actionCannel(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            if let _ = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
               CRMCallManager.shareInstance.closeWindow(withNameScreen: CRMCallHelpers.NameScreen.CustomerListViewController)
            } else {
                self.dismissViewController(self)
            }
        })
    }
    
    func myBoundsChangeNotificationHandler(withNotification :NSNotification) {
        let range = getVisibleRow()
        let local = range.location + range.length

        if isReplaceSearch && local == dataDict.count && indexScroll < local && totalPage > currentPage {
            
            indexScroll = local
            isReplaceSearch = false
            currentPage += 1
            
            searchCustomer()
        }
    }
    
    // MARK: - Func other
    private func enableControl(state: Bool) {
        searchButton.enabled = state
        if state {
            progressIndicator.stopAnimation(state)
            progressIndicator.hidden = state
        } else {
            progressIndicator.startAnimation(!state)
            progressIndicator.hidden = state
        }
    }

    // MARK: - SearchCustomer
    func searchCustomer() {
        
        if !CRMCallManager.shareInstance.isInternetConnect {
            if let w = self.view.window {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: w, title: "Notification", messageText: "Please check connect internet.", dismissText: "Cancel", completion: { result in })
            }
            return
        }
        
        enableControl(false)
        
        var types = [""]
        
        if TypesPopUpbutton.titleOfSelectedItem == CRMCallHelpers.CustomerType.ALL.rawValue {
            types = [CRMCallHelpers.TypeApi.Company.rawValue,
                     CRMCallHelpers.TypeApi.Contact.rawValue,
                     CRMCallHelpers.TypeApi.Employee.rawValue]

        }
        
        if TypesPopUpbutton.titleOfSelectedItem == CRMCallHelpers.CustomerType.Company.rawValue {
            types.append(CRMCallHelpers.TypeApi.Company.rawValue)
        }
        
        if TypesPopUpbutton.titleOfSelectedItem == CRMCallHelpers.CustomerType.Employee.rawValue {
            types.append(CRMCallHelpers.TypeApi.Employee.rawValue)
        }
        
        if TypesPopUpbutton.titleOfSelectedItem == CRMCallHelpers.CustomerType.Contact.rawValue {
            types.append(CRMCallHelpers.TypeApi.Contact.rawValue)
        }
        
        let pages  = [String(currentPage), String(offset)]
        var url = CRMCallConfig.API.searchCustomer(withCompany: CRMCallManager.shareInstance.cn, types: types, pages: pages, keyword: keySearchTextFeild.stringValue, sort: CRMCallHelpers.Sort.Name.rawValue, order: CRMCallHelpers.Order.Desc.rawValue)
        
        url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                
                if self.isReplaceSearch {
                    self.dataDict.removeAll()
                }
                
                println("-----------> SEARCH CUSTOMER DATA CALL RESPONCE: \(datas)")
                if let attrs = datas["attrs"] as? [String: AnyObject] {
                    
                    if let _totalPage = attrs["total_page"] as? Int {
                        self.totalPage = _totalPage
                    }
                    
                    if let _page = attrs["page"] as? Int {
                        self.currentPage = _page
                    }
                }
                
                if let data = datas["rows"] as? [[String: AnyObject]] {
                    
                    for item in data {
                        
                        if let phones = item["phone"] as? [[String: AnyObject]] {
                           
                            if phones.count == 0 {
                                var phoneItem = [String: AnyObject]()
                                phoneItem["label"] = ""
                                phoneItem["type"] = ""
                                phoneItem["value"] = ""
                                
                                var itemConfig = item
                                itemConfig["phone"] = phoneItem
                                self.dataDict.append(itemConfig)
                            } else {
                                for phone in phones {
                                    var itemConfig = item
                                    itemConfig["phone"] = phone
                                    //if (phone["value"] as! String) != "^^" {
                                    self.dataDict.append(itemConfig)
                                    // }
                                }
                            }
                        } else {
                            var phoneItem = [String: AnyObject]()
                            phoneItem["label"] = ""
                            phoneItem["type"] = ""
                            phoneItem["value"] = ""
                            
                            var itemConfig = item
                            itemConfig["phone"] = phoneItem
                            self.dataDict.append(itemConfig)
                        }
                    }
                    
                    self.tableViewCustomers.reloadData()
                    self.isReplaceSearch = true
                    self.enableControl(true)
                } else {
                    println("Not found SEARCH CUSTOMER from server")
                    self.enableControl(true)
                }
            } else {
                println("---XXXXX---->>> GET DATA SEARCH CUSTOMER FAIL WITH MESSAGE: \(datas)")
                self.enableControl(true)
            }
        }
    }
}

// MARK: - Delegate table
extension CustomerListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataDict.count ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let object = dataDict[row]
        
        if tableColumn?.identifier == "NameID" {
            return object["name"] as! String
        }
        
        if tableColumn?.identifier == "TypeID" {
            let value = object["type"] as! String
            return value.capitalizingFirstLetter()
        }
        
        if tableColumn?.identifier == "PhoneID" {
            
            if let phone = object["phone"] {
                let value = phone["value"] as! String

                return value.stringByReplacingOccurrencesOfString("^", withString: "")
            } else {
                return ""
            }
            
        } else {
            return object["company"] as! String
        }
    }
    
    func getVisibleRow() -> NSRange {
        if let scrollView = self.tableViewCustomers.enclosingScrollView {
            let visibleRect = scrollView.contentView.visibleRect
            let range = self.tableViewCustomers.rowsInRect(visibleRect)
            println("Range---: \(range)")
            return range
        }
        return NSRange()
    }
}
