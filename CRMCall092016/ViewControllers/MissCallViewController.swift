//
//  MissCallViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/24/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class MissCallViewController: NSViewController, ViewControllerProtocol {

    // MARK: - Properties
    @IBOutlet weak var popUpButtonTypeDirection: NSPopUpButtonCell!
    @IBOutlet weak var popUpButtonTypeCall: NSPopUpButton!
    @IBOutlet weak var missCallTable: NSTableView!
    
    
    private var missCallDict = [[String : AnyObject]]()
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("MissCallViewControllerID") as! MissCallViewController
    }
    
    func initData() {
        
    }
    
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        initData()
    }
    
    // MARK: - Handling event
    
    @IBAction func actionSearch(sender: AnyObject) {
        
    }
    @IBAction func actionOK(sender: AnyObject) {
        
    }
    
    func search() {
        var urlMissCall = CRMCallConfig.API.searchMissCall()
        
        urlMissCall = urlMissCall.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        AlamofireManager.requestUrlByGET(withURL: urlMissCall, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Search history Call responce <------------ \n \(datas)")
                
                
                if let attrs = datas["attr"] as? [String: AnyObject] {
                    
                    if let _totalPage = attrs["total"] as? Int {
                        //self.total = _totalPage
                    }
                }
                
                guard let data = datas["rows"] as? [[String: AnyObject]] else {
                    println("Cannot get data after register employee success")
                   // self.enableControl(true)
                    return
                }
            } else {
                println("---XXXXX---->>> Get Search history Call fail with message: \(datas)")
            }
        }
    }
}

// MARK: - Table deledate and datasource
extension MissCallViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return missCallDict.count ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let object = missCallDict[row]
        
        if tableColumn?.identifier == "DateID" {
            return object["subject"] as! String
        } else if tableColumn?.identifier == "StatusID" {
            return object["subject"] as! String
        } else if tableColumn?.identifier == "CompanyID" {
            return object["subject"] as! String
        } else if tableColumn?.identifier == "NameID" {
            return object["subject"] as! String
        } else if tableColumn?.identifier == "PhoneID" {
            return object["subject"] as! String
        }
        
        return nil
    }
}
