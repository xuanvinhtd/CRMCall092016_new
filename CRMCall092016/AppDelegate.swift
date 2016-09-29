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
        
        self.settingAppCall()
        
        // Register push notification
        let type: NSRemoteNotificationType = [NSRemoteNotificationType.Alert,NSRemoteNotificationType.Badge, NSRemoteNotificationType.Sound]
        NSApp.registerForRemoteNotificationTypes(type)
        // Insert code here to initialize your application
    }
    
    func settingAppCall() {
        // Config Realm
        Cache.shareInstance
        // Init Sigleton App
        CRMCallManager.shareInstance
        // Setting SIP
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult){
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("0", forKey: CRMCallConfig.UserDefaultKey.SIPLoginResult)
            defaults.synchronize()
        }
    }
    
    func application(application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = NSString(format: "%@", deviceToken) as String
        println("NOTIFICATION TOKEN: ---> \(deviceTokenString))")
    }
    
    func application(application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("NOTIFICATION ERROR: ----> \(error)")
    }
    
    func application(application: NSApplication, didReceiveRemoteNotification userInfo: [String : AnyObject]) {
        println("NOTIFICATION INFO ----> \(userInfo)")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func preferenceTouches(sender: AnyObject) {
        
    }

}

