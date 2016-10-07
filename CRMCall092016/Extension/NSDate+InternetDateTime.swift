//
//  NSDate+InternetDateTime.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/6/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

private var rfc3339formatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxx"
    return formatter
}()

private var dateTimeformatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()


extension NSDate {
    var stringFormattedAsRFC3339: String {
        return rfc3339formatter.stringFromDate(self)
    }
    
    var stringFormattedDateTime: String {
        return dateTimeformatter.stringFromDate(self)
    }

    
    convenience init?(RFC3339FormattedString:String) {
        if let d = rfc3339formatter.dateFromString(RFC3339FormattedString) {
            self.init(timeInterval:0,sinceDate:d)
        }
        else { return nil }
    }
}