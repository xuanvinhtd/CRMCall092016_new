//
//  AlamofireManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/8/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Alamofire

final class AlamofireManager {
    
    static func getData(withURL url: String, withCompletion completion: ((withData: NSData?) ->Void)?) {
    
        Alamofire.request(.GET, url)
            .responseString { response in
                
                println("\(response)")
                
                guard let Completion = completion else {
                    fatalError("Not found Closure completion")
                }
                
                if response.result.isSuccess {
                    
                    Completion(withData: response.data)

                } else {
                    println("get data by Alamofire fail")
                    Completion(withData: nil)
                }
        }
        
    }
}