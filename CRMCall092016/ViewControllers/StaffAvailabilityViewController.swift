//
//  StaffAvailabilityViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/14/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class StaffAvailabilityViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    @IBOutlet weak var sourceView: NSOutlineView!
    var tree: [String: AnyObject] = [:]
    var keysTree: [String] = []
    
    @IBOutlet weak var keySerchTextField: NSTextField!
    
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("StaffAvailabilityViewControllerID") as! StaffAvailabilityViewController
    }
    
    func initData() {
        
        ///-------------- GET ALL STAFF -------------//
        let url = CRMCallConfig.API.getAllStaffs()
        
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Get All Staff data responce: \(datas)")
                
                guard let data = datas["rows"] as? [[String: AnyObject]] else {
                    println("Cannot get data after register employee success")
                    return
                }
                
                self.tree = CRMCallHelpers.BuildTreeStaff(withData: data)
                self.keysTree = Array(self.tree.keys)
                self.sourceView.reloadData()
            } else {
                println("---XXXXX---->>> Get all staff data fail with message: \(datas)")
            }
        }
    }
    
    // MARK: - View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        // Do view setup here.
    }
    
    // MARK: - Handling event
    
    @IBAction func actionSearch(sender: AnyObject) {
        if keySerchTextField.stringValue == "" {
            initData()
            return
        }
        self.tree = CRMCallHelpers.SearchTreeStaff(withData: self.tree, andKeySearch: keySerchTextField.stringValue)
        self.keysTree = Array(self.tree.keys)
        //self.sourceView.e
        self.sourceView.reloadData()
    }
}
// MARK: - Outline View Data Source
extension StaffAvailabilityViewController: NSOutlineViewDataSource {
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        guard let item = item else {
            let test = self.tree[self.keysTree[index]] as! Root
            print("count = \(test.count())")
            return test
        }
        
        guard let displayable = item as? SourceListItemDisplayable else {
            assert(false, "outlineView:index:item: gave a dud item")
            return self
        }
        
        guard let child = displayable.childAtIndex(index) else {
            assert(false, "outlineView:index:item: gave a dud item")
            return self
        }
        
        return child
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        
        guard let display = item as? SourceListItemDisplayable else { return false }
        
        if let displayable = display as? Root {
            return displayable.count() > 0
        } else {
            if let displayable = display as? RootI {
                return displayable.count() > 0
            } else {
                if let displayable = display as? Child {
                    return displayable.count() > 0
                } else {
                    return false
                }
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil { return self.tree.count }
        
        guard let display = item as? SourceListItemDisplayable else { return 0 }
        
        if let displayable = display as? Root {
            return displayable.count()
        } else {
            if let displayable = display as? RootI {
                return displayable.count()
            } else {
                if let displayable = display as? Child {
                    return displayable.count()
                } else {
                    return 0
                }
            }
        }
    }
}

// MARK: - Outline View Data Delegate
extension StaffAvailabilityViewController: NSOutlineViewDelegate {
    func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // Ensure that the passed item is valid and can be used to create a table cell
        guard let displayable = item as? SourceListItemDisplayable,
            view = outlineView.makeViewWithIdentifier(displayable.cellID(), owner: self) as? NSTableCellView
            else { return nil }
        
        // If we have a text field, set it to the item's name
        if let textField = view.textField {
            textField.stringValue = displayable.name
        }
        
        // If we have animage view, set it to the item's icon
        if let imageView = view.imageView {
            imageView.image = displayable.icon
        }
        
        return view
    }
}
