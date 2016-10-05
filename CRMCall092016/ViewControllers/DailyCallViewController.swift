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
    
    func configItems() {
        //NSTapGes
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init DailyCallViewController Screen")
        
        initData()
        configItems()
        
        
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
    
    @IBAction func actionSave(sender: AnyObject) {
        
        if let dailyWindwoController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.DailyCallWindowController] {
            dailyWindwoController.close()
            CRMCallManager.shareInstance.screenManager.removeValueForKey(CRMCallHelpers.NameScreen.DailyCallWindowController)
        }
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
        
        popover.showRelativeToRect(positioningRect, ofView: positioningView as! NSButton, preferredEdge: preferredEdge)
    }
    
    @IBAction func actionShowSubject(sender: AnyObject) {
        
    }
}

//MARK: - Popover Delegate

extension DailyCallViewController: NSPopoverDelegate {
    
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
//    
//    func detachableWindowForPopover(popover: NSPopover) -> NSWindow? {
//        return (windowTypeSelection.selectedRow == 1) ? detachedWindowController.window : nil
//    }
    
    func popoverDidShow(notification: NSNotification) {
        println("click show")
    }
    
    func popoverDidClose(notification: NSNotification) {
        let closeReason = notification.userInfo![NSPopoverCloseReasonKey] as! String
        if (closeReason == NSPopoverCloseReasonStandard) {
            println("click close")
        }
    }
}
