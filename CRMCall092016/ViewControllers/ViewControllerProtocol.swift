//
//  ViewControllerProtocol.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/23/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol ViewControllerProtocol {
    
    static func createInstance() -> NSViewController
    
    optional func initData()
    optional func configItems()
    optional func registerNotification()
    optional func deregisterNotification()
    
}