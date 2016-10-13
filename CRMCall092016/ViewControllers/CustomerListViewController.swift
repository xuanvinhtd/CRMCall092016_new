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
    
    private var dataDict = [[String: AnyObject]]()
    private var indexStart = 0
    private var offset = 15
    
    private var itemSelect = [String: AnyObject]()
    
    var keySearchInit = ""
    
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

    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configItems()
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.title = "Customers List"
        
    }
    
    // MARK: - Handing event
    
    @IBAction func actionSeach(sender: AnyObject) {
        searchCustomer()
    }
    
    @IBAction func actionUnregister(sender: AnyObject) {
        delegate?.chooseCustomer(withDict: nil)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if let lcustomerListWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
                lcustomerListWindowController.close()
                CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.CustomerListViewController)
            }
        })

    }
    
    @IBAction func actionOK(sender: AnyObject) {
        
        for (_, index) in tableViewCustomers.selectedRowIndexes.enumerate() {
            itemSelect = dataDict[index]
        }
        
        if itemSelect.count == 0 {
            CRMCallAlert.showNSAlertSheet(with: NSAlertStyle.InformationalAlertStyle, window: self.view.window!, title: "Notification", messageText: "Please select customer", dismissText: "Cancel", completion: { result in })
            return
        }
        
        delegate?.chooseCustomer(withDict: itemSelect)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if let lcustomerListWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
                lcustomerListWindowController.close()
                CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.CustomerListViewController)
            }
        })

    }
    
    @IBAction func actionCannel(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            
            if let lcustomerListWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
                lcustomerListWindowController.close()
                CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.CustomerListViewController)
            }
        })
    }

    // MARK: - SearchCustomer
    func searchCustomer() {
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
        
        let pages  = [String(indexStart), String(indexStart + offset)]
        var url = CRMCallConfig.API.searchCustomer(withCompany: CRMCallManager.shareInstance.cn, types: types, pages: pages, keyword: keySearchTextFeild.stringValue, sort: CRMCallHelpers.Sort.Name.rawValue, order: CRMCallHelpers.Order.Desc.rawValue)
        
        url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                self.dataDict.removeAll()
                
                println("-----------> SEARCH CUSTOMER DATA CALL RESPONCE: \(datas)")
                
                if let data = datas["rows"] as? [[String: AnyObject]] {
                    
                    for item in data {
                        
                        if let phones = item["phone"] as? [[String: AnyObject]] {
                           
                            for phone in phones {
                                var itemConfig = item
                                itemConfig["phone"] = phone
                                if (phone["value"] as! String) != "^^" {
                                    self.dataDict.append(itemConfig)
                                }
                            }
                        } else {
                            var phoneItem = [String: AnyObject]()
                            phoneItem["label"] = ""
                            phoneItem["type"] = ""
                            phoneItem["value"] = ""
                            
                            var itemConfig = item
                            itemConfig["phone"] = phoneItem
                            
                            //self.dataDict.append(itemConfig)
                        }
                    }
                    
                    self.tableViewCustomers.reloadData()
                } else {
                    println("Not found SEARCH CUSTOMER from server")
                }
            } else {
                println("---XXXXX---->>> GET DATA SEARCH CUSTOMER FAIL WITH MESSAGE: \(datas)")
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
    
    
}
