//
//  AppDelegate.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Config Realm
        Cache.shareInstaince
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

