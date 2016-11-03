//
//  HistorySearchDialogWindowController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 11/3/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class HistorySearchDialogWindowController: NSWindowController {

    // MARK: - Initialzation
    static func createInstance() -> NSWindowController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("HistorySearchDialogWindowControllerID") as! HistorySearchDialogWindowController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
