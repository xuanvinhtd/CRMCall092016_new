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
    
    static let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
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
                
                print("URL: -->\(response.request)")
                print("Header: -->\(parameter)")
                
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
    
    static func requestUrlByPOST(withURL url: String, parameter: [String: AnyObject], Completion completion: ((data: [String: AnyObject], success: Bool) ->Void)?) {
        
        var result: [String: AnyObject]? = [:]
        
        Manager.request(.POST, url, parameters: parameter, encoding: .JSON)
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
    
    static func requestUrlByPUT(withURL url: String, parameter: [String: AnyObject], Completion completion: ((data: [String: AnyObject], success: Bool) ->Void)?) {
        
        var result: [String: AnyObject]? = [:]
        
        Manager.request(.PUT, url, parameters: parameter)
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
    
    static func requestUrlByGET(withURL url: String, parameter: [String: String]?, Completion completion: ((data: [String: AnyObject], success: Bool) ->Void)?) {
        
        var result: [String: AnyObject]? = [:]
        
        Manager.request(.GET, url, parameters: parameter)
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
    
    static func isConnetInternet() -> Bool {
        // CHECK INTERNET
        if let re = reachabilityManager {
            if re.isReachable {
                println("----> connect internet")
                return true
            } else {
                println("--> not connet internet")
                return false
            }
        } else {
            println("--> not connet, init")
            return false
        }
    }
    
    static func startNetworkReachabilityObserver() {
        
        // start listening
        reachabilityManager!.startListening()
        
        reachabilityManager!.listener = { status in
            
            switch status {
                
            case .NotReachable:
                print("The network is not reachable")
                CRMCallManager.shareInstance.deinitSocket()
                CRMCallManager.shareInstance.isInternetConnect = false
                
                NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.NotConnetInternet, object: nil, userInfo: nil)
                
                break
            case .Unknown :
                print("It is unknown whether the network is reachable")
                break
                
            case .Reachable(.EthernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                if !CRMCallManager.shareInstance.isInternetConnect {
                    NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.ReConnectSocket, object: nil, userInfo: nil)
                }
                
                if CRMCallManager.shareInstance.isShowLoginPage && !CRMCallManager.shareInstance.isInternetConnect {
                    CRMCallManager.shareInstance.isInternetConnect = true
                     NSNotificationCenter.defaultCenter().postNotificationName(LoginViewController.Notification.Relogin, object: nil, userInfo: nil)
                }
                
                CRMCallManager.shareInstance.isInternetConnect = true
                break
                
                
            case .Reachable(.WWAN):
                print("The network is reachable over the WWAN connection")
                if !CRMCallManager.shareInstance.isInternetConnect {
                    NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.ReConnectSocket, object: nil, userInfo: nil)
                }
                
                if CRMCallManager.shareInstance.isShowLoginPage && !CRMCallManager.shareInstance.isInternetConnect {
                    CRMCallManager.shareInstance.isInternetConnect = true
                    NSNotificationCenter.defaultCenter().postNotificationName(LoginViewController.Notification.Relogin, object: nil, userInfo: nil)
                }

                CRMCallManager.shareInstance.isInternetConnect = true
                break
            }
        }
    }
}