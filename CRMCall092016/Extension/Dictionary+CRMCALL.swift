//
//  Dictionary+CRMCALL.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/3/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    
    func someKeyFor(value: Value) -> Key? {
        
        guard let index = indexOf({ $0.1 == value }) else {
            return nil
        }
        
        return self[index].0
    }
}
