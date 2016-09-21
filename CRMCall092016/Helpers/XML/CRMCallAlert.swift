//
//  CRMCallAlert.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/20/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//
import Cocoa
import Foundation

final class CRMCallAlert {
    
    class func showNSAlert(with alertStyle: NSAlertStyle, title: String, messageText: String, dismissText: String, completion: ((Bool) ->Void)?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let myAlert = NSAlert()
            myAlert.messageText = messageText
            myAlert.informativeText = title
            myAlert.alertStyle = alertStyle
            myAlert.addButtonWithTitle(dismissText)
            let res = myAlert.runModal()
            
            guard let completion = completion else {
                println("Not found clouse completion")
                return
            }
            
            if res == NSAlertFirstButtonReturn {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    class func showNSAlertSheet(with alertStyle: NSAlertStyle, window: NSWindow, title: String, messageText: String, dismissText: String, completion: ((Bool) ->Void)?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let myAlertSheet = NSAlert()
            myAlertSheet.messageText = messageText
            myAlertSheet.informativeText = title
            myAlertSheet.alertStyle = alertStyle
            myAlertSheet.addButtonWithTitle(dismissText)
            let res = myAlertSheet.runModal()
            
            guard let completion = completion else {
                println("Not found clouse completion")
                return
            }
            
            myAlertSheet.beginSheetModalForWindow(window, completionHandler: { responce in
                completion(true)
            })
        }
    }

}