//
//  CRMCallHelpers.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/14/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

final class CRMCallHelpers {
    
    static let storyBoard = NSStoryboard.init(name: "Main", bundle: nil)
    static let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    enum TypeData {
        case UserLogin
        case UserLogout
        case UserInfo
        case ServerInfo
        case UserLive
        case SIP
        case RingIng
        case None
    }
    
    enum UserStatus: String {
        case None = "0"
        case Ringing = "1"
        case Busy = "2"
    }
    
    enum Direction: String {
        case None = "NONE"
        case InBound = "INBOUND"
        case OutBound = "OUTBOUND"
    }
    
    enum Event: String {
        case Invite = "INVITE"
        case Cancel = "CANCEL"
        case Busy = "BUSY"
        case InviteResult = "INVITE_RESULT"
        case Bye = "BYE"
    }
    
    static func getUUID() -> String {
        if let uuid = NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UUIDKey) {
            return uuid
        } else {
            let uuidObject = CFUUIDCreate(kCFAllocatorDefault)
            let uuid = CFUUIDCreateString(kCFAllocatorDefault, uuidObject)
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: CRMCallConfig.UUIDKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            return uuid as String
        }
    }
}