//
//  MissCallWindowController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/24/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class MissCallWindowController: NSWindowController {

    // MARK: - Initialzation
    static func createInstance() -> NSWindowController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("MissCallWindowControllerID") as! MissCallWindowController
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
