//
//  DailyCallViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/30/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class DailyCallViewController: NSViewController, ViewControllerProtocol {

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
    @IBOutlet weak var subjectTextField: NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var addTaskButton: NSButton!
    @IBOutlet weak var createTicketButton: NSButton!
    @IBOutlet weak var historyButton: NSButton!
    
    @IBOutlet weak var historyTableView: NSTableView!
    
    private var addressDict = ["":""]
    private var purposeList: [[String: String]] = [[String: String]]()
    private var productList: [[String: String]] = [[String: String]]()
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("DailyCallViewControllerID") as! DailyCallViewController
    }
    
    func initData() {
        
        // GET TYPE PHONE
        var url = CRMCallConfig.API.phoneType()
        let parameter = RequestBuilder.cookies()
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Data type phone = \(datas)")
                
                if let address = datas["address"] as? [String: String] {
                    self.addressDict = address
                    
                    let arrString = Array(address.values)
                    self.phoneTypePopUpBtn.addItemsWithTitles(arrString)

                } else {
                    println("Not found address from server")
                }
                
            } else {
                println("-----------> Data type fail = \(datas)")
            }
        }
        
        // GET PURPOSE LIST
        url = CRMCallConfig.API.purposeList(withCNKey: "102", lang: "en")
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Data purpose  = \(datas)")
                
                if let data = datas["rows"] as? [[String: String]] {
                    self.purposeList = data
                } else {
                    println("Not found purpose list from server")
                }

                println("----> \(self.purposeList)")
            } else {
                println("-----------> Data purpose fail = \(datas)")
            }
        }
        
        // GET PRODUCT LIST
        url = CRMCallConfig.API.productList(withCNKey: "102")
        AlamofireManager.requestUrlByGET(withURL: url, parameter: parameter) { (datas, success) in
            if success {
                println("-----------> Data product list  = \(datas)")
                
                if let data = datas["rows"] as? [[String: String]] {
                    self.productList = data
                } else {
                    println("Not found product list from server")
                }
                
                println("----> \(self.purposeList)")
            } else {
                println("-----------> Data purpose fail = \(datas)")
            }
        }

    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init DailyCallViewController Screen")
        
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.title = "Daily Call"
    }
    
    // MARK: - Handling event
    
    @IBAction func actionShowHistory(sender: AnyObject) {

        println("--> index \(self.phoneTypePopUpBtn.indexOfSelectedItem)")
        println("--> title \(CRMCallHelpers.findKeyForValue(self.phoneTypePopUpBtn.titleOfSelectedItem!, dictionary: self.addressDict))")
    }
    
}
