//
//  AppDelegate.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var signInMenuItem: NSMenuItem!
    @IBOutlet weak var signOutMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.settingAppCall()
        
        Fabric.with([Crashlytics.self])
        
        // Register push notification
        let type: NSRemoteNotificationType = [NSRemoteNotificationType.Alert,NSRemoteNotificationType.Badge, NSRemoteNotificationType.Sound]
        NSApp.registerForRemoteNotificationTypes(type)
        // Insert code here to initialize your application        
    }
    
    func settingAppCall() {
        
        // Cache result SIPLogin
        //let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setObject("3", forKey: CRMCallConfig.UserDefaultKey.SIPLoginResult)
        
        AlamofireManager.startNetworkReachabilityObserver()
        // Config Realm
        Cache.shareInstance
        
        for window in NSApp.windows{
            if let w = window.windowController  {
                
                if let vc = w.contentViewController {
                    if vc.isKindOfClass(LoginViewController) {
                        CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.LoginWindowController] = w
                    }
                }
            }
        }
        
        // Setting SIP
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.SIPLoginResult){
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("0", forKey: CRMCallConfig.UserDefaultKey.SIPLoginResult)
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
        
        
            for window in sender.windows{
                if let w = window as NSWindow? {
                   
                    if let viewControl = w.windowController  {
                        if let vc = viewControl.contentViewController {
                            if vc.isKindOfClass(LoginViewController) {
                                CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.LoginWindowController] = viewControl
                            }
                        }
                    }
                    
                    if let viewControl = w.windowController  {
                        if let vc = viewControl.contentViewController {
                            if vc.isKindOfClass(SettingViewController) {
                                CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.SettingViewController] = viewControl
                            }
                        }
                    }
                    
                    if !CRMCallManager.shareInstance.isShowSettingPage  {
                        w.makeKeyAndOrderFront(self)
                    }
                }
        }
        
        println("Screen count: \(CRMCallManager.shareInstance.screenManager.count)")
        
        return true
    }
    
    // MARK: - Handling event menu

    @IBAction func showSignInPage(sender: AnyObject) {
        
        CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.LoginWindowController)
    }
    
    @IBAction func showSignOutPage(sender: AnyObject) {
        
        CRMCallManager.shareInstance.deinitSocket()
        
        CRMCallManager.shareInstance.isShowMainPage = false
        CRMCallManager.shareInstance.isUserLoginSuccess = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(0, forKey: CRMCallConfig.UserDefaultKey.AutoLogin)
        
        NSNotificationCenter.defaultCenter().postNotificationName(MainViewController.Notification.ShowPageSigin, object: nil, userInfo: nil)
    }
    
    @IBAction func showStaffAvailiblity(sender: AnyObject) {
        
        if !CRMCallManager.shareInstance.isUserLoginSuccess {
            CRMCallAlert.showNSAlert(with: .InformationalAlertStyle, title: "Notification", messageText: "You must login before", dismissText: "Cancel", completion: { (rs) in
                
            })
            return
        }
        
        CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.StaffAvailabilityWindowController)
    }
    
    @IBAction func showMissedCalls(sender: AnyObject) {
        
    }
    
    @IBAction func showCustomerList(sender: AnyObject) {
        
        if !CRMCallManager.shareInstance.isUserLoginSuccess {
            CRMCallAlert.showNSAlert(with: .InformationalAlertStyle, title: "Notification", messageText: "You must login before", dismissText: "Cancel", completion: { (rs) in
                
            })
            return
        }
        
        if let customerListWindowController = CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] {
            
            let viewController = customerListWindowController.contentViewController as! CustomerListViewController
            viewController.isCustomerListReviews = true
            viewController.searchCustomer()
            
            customerListWindowController.showWindow(nil)
        } else {
            
            let customerListWindowController = CustomerListWindowController.createInstance()
            let viewController = customerListWindowController.contentViewController as! CustomerListViewController
            viewController.isCustomerListReviews = true
            viewController.searchCustomer()
            customerListWindowController.showWindow(nil)
            
            CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.CustomerListViewController] = customerListWindowController
        }
    }
    
    @IBAction func showAddToHistoryCall(sender: AnyObject) {
        
    }
    
    @IBAction func showRemote(sender: AnyObject) {
        
    }
    
    @IBAction func actionAddSound(sender: AnyObject) {
        
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent("Sound")
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(dataPath) {
            do {
                try fileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a file sound"
        openPanel.allowedFileTypes = ["mp3", "wav","mp4"]
        openPanel.beginWithCompletionHandler { (result) in
            if result == NSFileHandlingPanelOKButton {
                
                let nameFile = "ring.wav"
                let toUrl = NSURL(fileURLWithPath: dataPath + "/" + nameFile)
                
                let fileUrl = openPanel.URL!
                
                println("url = \(fileUrl) to url = \(toUrl)")
                
                NSUserDefaults.standardUserDefaults().setObject("Sound/\(nameFile)", forKey: CRMCallConfig.UserDefaultKey.PathLocalSound)

                if fileManager.fileExistsAtPath(toUrl.absoluteString) {
                    do {
                        try fileManager.replaceItemAtURL(fileUrl, withItemAtURL: toUrl, backupItemName: nameFile, options: NSFileManagerItemReplacementOptions.WithoutDeletingBackupItem, resultingItemURL: nil)
                    } catch let error as NSError {
                        
                        do {
                            try fileManager.copyItemAtURL(fileUrl, toURL: toUrl)
                        } catch let error as NSError {
                            println("Cannot move file: \(nameFile) to url = \(toUrl), Error: \(error)")
                        }
                        
                        println("Cannot replace file at url: \(toUrl.absoluteString) with error: \(error)")
                    }
                }
                
            }
        }
    }

    
    @IBAction func showSettingCall(sender: AnyObject) {
        CRMCallManager.shareInstance.showWindow(withNameScreen: CRMCallHelpers.NameScreen.SettingViewController)
    }
    
    @IBAction func showCRMCall(sender: AnyObject) {
        
        for window in NSApp.windows{
            if let w = window as NSWindow? {
                
                if let viewControl = w.windowController  {
                    if let vc = viewControl.contentViewController {
                        if vc.isKindOfClass(LoginViewController) {
                            CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.LoginWindowController] = viewControl
                        }
                    }
                }
                
                if let viewControl = w.windowController  {
                    if let vc = viewControl.contentViewController {
                        if vc.isKindOfClass(SettingViewController) {
                            CRMCallManager.shareInstance.screenManager[CRMCallHelpers.NameScreen.SettingViewController] = viewControl
                        }
                    }
                }
                if !CRMCallManager.shareInstance.isShowSettingPage  {
                    w.makeKeyAndOrderFront(self)
                }
            }
        }
        
        println("Screen count: \(CRMCallManager.shareInstance.screenManager.count)")
    }
    
}

