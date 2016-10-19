//
//  PopUptViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/4/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import AppKit

@objc(PopUpViewController) class PopUpViewController: NSViewController {
    
    // MARK: Properties
    @IBOutlet weak var dataTableView: NSTableView!
    
    var dataDict = [NSMutableDictionary]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reloadTable() {
        if dataTableView != nil {
            dataTableView.reloadData()
        }
    }
}

extension PopUpViewController: NSTableViewDelegate, NSTableViewDataSource {
 
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (dataDict.count - 1) ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {

        let object = dataDict[row] as NSMutableDictionary
        
        if tableColumn?.identifier == "NameID" {
            return object[(tableColumn?.identifier)!] as! String
        } else {
            return object[(tableColumn?.identifier)!] as! Int
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        dataDict[row].setObject(object!, forKey: (tableColumn?.identifier)!)
    }
    
}