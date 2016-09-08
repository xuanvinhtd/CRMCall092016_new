//
//  CRMCallLog.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

func println(@autoclosure item: () -> Any) {
    
    #if DEBUG
        Swift.print(item())
    #endif
    
}