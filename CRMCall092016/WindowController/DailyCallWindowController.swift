//
//  DailyCallWindowController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/30/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class DailyCallWindowController: NSWindowController {

    // MARK: - Initialzation
    static func createInstance() -> NSWindowController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("DailyCallWindowControllerID") as! DailyCallWindowController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
    }

}
