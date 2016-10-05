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
    
    var dataPurpose = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataTableView.setDelegate(self)
        dataTableView.setDataSource(self)
    }
}

extension PopUpViewController: NSTableViewDelegate, NSTableViewDataSource {
 
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataPurpose.count ?? 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {

        
        if tableColumn == tableView.tableColumns[0] {
            
            if let cell = tableView.makeViewWithIdentifier("PurporseNameCellID", owner: nil)  {
                
                return cell
            }
            
        } else if tableColumn == tableView.tableColumns[1] {
            
            if let cell = tableView.makeViewWithIdentifier("ChooseCellID", owner: nil) as? NSButtonCell {
                
                return cell
            }
        }

        return nil
    }
    
}