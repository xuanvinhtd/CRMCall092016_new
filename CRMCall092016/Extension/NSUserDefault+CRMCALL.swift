//
//  NSUserDefault+CRMCALL.swift
//  CRMCall092016
//
//  Created by Hanbiro on 11/8/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

extension NSUserDefaults {
    subscript(key: String) -> Any? {
        get {
            return objectForKey(key)
        }
        set {
            if let v = newValue as? String {
                setObject(v, forKey: key)
            } else if let v = newValue as? Int {
                setInteger(v, forKey: key)
            } else if let v = newValue as? Bool {
                setBool(v, forKey: key)
            } else if let v = newValue as? Float {
                setFloat(v, forKey: key)
            } else if newValue == nil {
                removeObjectForKey(key)
            } else {
                assertionFailure("Invalid value type")
            }
            
        }
    }
    
    func hasKey(key: String) -> Bool {
        return objectForKey(key) != nil
    }
}
