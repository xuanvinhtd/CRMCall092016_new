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
    
    private static var Managerx : Alamofire.Manager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "https://global3.hanbiro.com": .DisableEvaluation
        ]
        // Create custom manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let man = Alamofire.Manager(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return man
    }()
    
    static var Manager : Alamofire.Manager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "global3.hanbiro.com": .DisableEvaluation
        ]
        // Create custom manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let man = Alamofire.Manager(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return man
    }()
    
    static func requestUrlByPOST(withURL url: String, parameter: [String: String], Completion completion: ((data: [String: AnyObject], success: Bool) ->Void)?) {
        
        var result: [String: AnyObject]? = [:]
        
        Manager.request(.POST, url, parameters: parameter)
            .responseJSON { response in
                
                print(response.request)
                
                if response.result.isSuccess {
                    guard let resultQ = response.result.value as? [String: AnyObject] else {
                        println("Do not convert data to dictionary at data get from Server")
                        return
                    }
                    result = resultQ
                } else {
                    result = nil
                }
                
                guard let completion = completion else {
                    println("Not found clouse completion")
                    return
                }
                
                guard let rs = result else {
                    println("Data from Server = nil")
                    completion(data: ["msg":"Please check login info again"],success: false)
                    return
                }
                
                if let isSuccess = rs["success"] as? Bool {
                    completion(data: rs, success:  isSuccess)
                } else {
                    completion(data: rs, success:  true)
                }
        }
    }
}