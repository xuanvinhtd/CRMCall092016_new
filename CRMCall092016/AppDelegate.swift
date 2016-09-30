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
    
    // MARK: - Properties
    @IBOutlet weak var signInMenuItem: NSMenuItem!
    @IBOutlet weak var signOutMenuItem: NSMenuItem!
    
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
        
        for window in NSApp.windows{
            if let w = window.windowController  {
            CRMCallManager.shareInstance.screenManager["LoginWindowController"] = w
            }
        }
        
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
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if !flag{
            
            for window in sender.windows{
                if let w = window as NSWindow? {
                    w.makeKeyAndOrderFront(self)
                }
            }
        }
        return true
    }
    
    // MARK: - Handling event menu

    @IBAction func showSignInPage(sender: AnyObject) {
        
        if let loginWindowController = CRMCallManager.shareInstance.screenManager["LoginWindowController"] {
            loginWindowController.showWindow(nil)
        } else {
            let loginWindowController = LoginWindowController.createInstance()
            loginWindowController.showWindow(nil)
            CRMCallManager.shareInstance.screenManager["LoginWindowController"] = loginWindowController
        }
    }
    
    @IBAction func showSignOutPage(sender: AnyObject) {
        
        CRMCallManager.shareInstance.isShowMainPage = false
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(0, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
        
        NSNotificationCenter.defaultCenter().postNotificationName(MainViewController.Notification.ShowPageSigin, object: nil, userInfo: nil)
    }
    
    @IBAction func showCRMCall(sender: AnyObject) {
        for window in NSApp.windows{
            if let w = window as NSWindow? {
                w.makeKeyAndOrderFront(self)
            }
        }
    }
    
}

