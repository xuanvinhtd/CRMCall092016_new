//
//  SocketManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class BaseSocket: NSObject {
    
    // MARK: - Properties
    private var flagEncrypt: String = "1"
    private var readTimeOut: Double = 60.0
    private var writeTimeOut: Double = 5.0
    
    var isConnectedToHost: Bool = false
    
    private var aesExtension: AESExtension
    private var asynSocket: GCDAsyncSocket!
    
    private var socketQueue: dispatch_queue_t
    
    var port: UInt16
    var host: String
    
    // MARK: - Initialize
    
    override init() {
        
        self.host = ""
        self.port = 0
        self.aesExtension = AESExtension()
        
        self.socketQueue = dispatch_queue_create("Socket.queue", DISPATCH_QUEUE_SERIAL)
        
        super.init()
        
        self.asynSocket = GCDAsyncSocket(delegate: self, delegateQueue: self.socketQueue)

        //getIdAndHost()
    }
    
    deinit {
        self.asynSocket = nil
    }
    
    // MARK: - Socket handling
    
    func connect() {
        connect(withPort: self.port, host: self.host)
    }
    
    func connect(withPort port: UInt16, host: String) {
        
        dispatch_async(socketQueue) {
            do {
                if host != "" && port != 0 {
                    try self.asynSocket.connectToHost(host, onPort: port)
                } else {
                    println("Not enought info host and port")
                }
                
            } catch let err {
                println("Error connect socket: \(err)")
            }
        }
    }
    
    func disConnect() {
        
        asynSocket.disconnect()
        
        isConnectedToHost = false
    }
    
    func configAndSendData(withData strData: String) {
        
        dispatch_async(socketQueue) {
            println("Data request server: \(strData)")
            let encryptData = self.aesExtension.aesEncryptString(strData)
            
            let headerData = String(format: "%05lu", (encryptData?.characters.count)! + 1)
            
            let requestData = headerData + String(format: "%@%@", self.flagEncrypt, encryptData!)
            
            self.sendData(requestData.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
    
    private func sendData(data: NSData) {
        
        asynSocket.writeData(data, withTimeout: writeTimeOut, tag: CRMCallConfig.Tab.Default)
        
    }
    
    func getIdAndHost(withHostName hostName: String) {
        
        AlamofireManager.getData(withURL: CRMCallConfig.API.GetPortAndHostURL(withHostName: hostName)) { response in
            
            guard let _response = response else {
                println("Cannot get port and host to hostName: \(hostName)")
                return
            }
            
            guard let xml = NSString(data: _response, encoding: NSUTF8StringEncoding) as? String else {
                println("Not found data to server")
                return
            }
            
            SWXMLHashManager.parseXMLToDictionary(withXML: xml, Completion: { result, typeData in
                
                if typeData == CRMCallHelpers.TypeData.ServerInfo {
                    
                    if let port = result["PORT"], host = result["IP"] {
                        self.port = UInt16(port)!
                        self.host = host
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.RecivedServerInfor, object: nil, userInfo: nil)
                    } else {
                        println("Cannot parse port and host: \(hostName)")
                    }
                }
            })
        }
    }
}

// MARK: - Socket Delegate
extension BaseSocket: GCDAsyncSocketDelegate {
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        
        dispatch_async(self.socketQueue) {
            
            
            if tag == CRMCallConfig.Tab.Header {
                
                guard let headerData = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                    fatalError("Not found header data")
                }
                
                println("Recived data header: \(headerData)")
                
                let lenghtHeader = (UInt(headerData.substringToIndex(5))! - 1)
                self.flagEncrypt = headerData.substringFromIndex(5)
                
                self.asynSocket.readDataToLength(lenghtHeader, withTimeout: self.readTimeOut , tag: CRMCallConfig.Tab.BodyData)
                
                if lenghtHeader == 0 {
                    self.asynSocket.readDataToLength(CRMCallConfig.HeaderLength, withTimeout: self.readTimeOut, tag: CRMCallConfig.Tab.Header)
                }
                
            } else if (tag == CRMCallConfig.Tab.BodyData) {
                
                guard let bodyData = NSString(data: data, encoding: NSUTF8StringEncoding) as? String else {
                    fatalError("Not found body data")
                }
                
                var decryptBodyData = ""
                
                if self.flagEncrypt == "1" {
                    
                    guard let dataDecrypt = self.aesExtension.aesDecryptString(bodyData) else {
                        fatalError("Not Decrypt body data")
                    }
                    
                    decryptBodyData = dataDecrypt
                } else {
                    decryptBodyData = bodyData
                }
                
                println("Recived data body: \(decryptBodyData)")
                
                self.asynSocket.readDataToLength(CRMCallConfig.HeaderLength, withTimeout: self.readTimeOut, tag: CRMCallConfig.Tab.Header)
                
                self.cacheData(with: decryptBodyData)
            }
        }
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        println("Did connet to host: \(host) and post: \(port)")
        
        isConnectedToHost = true
        
        asynSocket.readDataToLength(CRMCallConfig.HeaderLength, withTimeout: readTimeOut, tag: CRMCallConfig.Tab.Header)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.SocketDidConnected, object: nil, userInfo: nil)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        
        println("Error Disconnect: \(err)")
        
        self.isConnectedToHost = false
        
        if CRMCallManager.shareInstance.isUserLoginSuccess {
            NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.ReConnectSocket, object: nil, userInfo: nil)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.SocketDisConnected, object: nil, userInfo: nil)
        }
    }
    
    // MARK: - Cache data get from server
    private func cacheData(with xmlData: String) {
        SWXMLHashManager.parseXMLToDictionary(withXML: xmlData, Completion: { result, typeData in
            
            if typeData == .UserLogout {
                
                NSNotificationCenter.defaultCenter().postNotificationName(LoginViewController.Notification.LogoutSuccess, object: nil, userInfo: nil)
            }
            
            if typeData == .UserLogin {
                
                if result["RESULT"] == "1" {
                    NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.LiveServer, object: nil, userInfo: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.LoginSuccessSocket, object: nil, userInfo: nil)
                    
                    // CACHES USER DATA
                    dispatch_async(Cache.shareInstance.realmQueue, {
                        Cache.shareInstance.userInfo(with: result)
                    })
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.LoginFailSocket, object: nil, userInfo: nil)
                }
                
                if result["RESULT"] == "2" {
                    NSNotificationCenter.defaultCenter().postNotificationName(SettingViewController.Notification.SIPLoginFaile, object: nil, userInfo: nil)
                    
                } else if result["RESULT"] == "3" {
                    NSNotificationCenter.defaultCenter().postNotificationName(SettingViewController.Notification.SIPHostFaile, object: nil, userInfo: nil)
                }
            }
            
            if typeData == .UserLive {
                
                if result["RESULT"] == "1" {
                    println("PING SUCCESS")
                } else {
                    println("PING FAIL")
                }
            }
            
            if typeData == .UserInfo {
                
                println("---------> Customer Data: \n\(result)")
                //CACHE
//                if result["RESULT"] == "1" {
//                    Cache.shareInstance.customerInfo(with: result, staffList: nil, productList: nil)
//                } else {
//                    
//                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(RingIngViewController.Notification.Show, object: nil, userInfo: nil)
            }
            
            if typeData == .SIP {
                
                if result["RESULT"] == "1" {
                    println("SIPLOGIN SUCCESS")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(SettingViewController.Notification.SIPLoginSuccess, object: nil, userInfo: nil)
                    
                    // Cache result SIPLogin
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(result["RESULT"], forKey: CRMCallConfig.UserDefaultKey.SIPLoginResult)
                    defaults.synchronize()
                } else {
                    println("SIPLOGIN FAIL")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(SettingViewController.Notification.SIPLoginFaile, object: nil, userInfo: nil)
                    
                    // Cache result SIPLogin
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject("0", forKey: CRMCallConfig.UserDefaultKey.SIPLoginResult)
                    defaults.synchronize()
                }
            }
            
            if typeData == .RingIng {
                println("DATA RingIng:-------------> \n \(result)")
                
                Cache.shareInstance.ringInfo(with: result)
                
                if let direction = result["DIRECTION"] {
                    if  direction == CRMCallHelpers.Direction.InBound.rawValue {
                        CRMCallManager.shareInstance.myCurrentDirection = .InBound
                    } else if  direction == CRMCallHelpers.Direction.OutBound.rawValue {
                        CRMCallManager.shareInstance.myCurrentDirection = .OutBound
                    } else {
                        CRMCallManager.shareInstance.myCurrentDirection = .None
                    }
                } else {
                    CRMCallManager.shareInstance.myCurrentDirection = .None
                }

                if let event = result["EVENT"] {
                    if  event == CRMCallHelpers.Event.Invite.rawValue {
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.InviteEvent, object: nil, userInfo: result)
                        
                        CRMCallManager.shareInstance.myCurrentStatus = CRMCallHelpers.UserStatus.Ringing
                    }
                    if  event == CRMCallHelpers.Event.InviteResult.rawValue {
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.InviteResultEvent, object: nil, userInfo: result)
                        
                        CRMCallManager.shareInstance.myCurrentStatus = CRMCallHelpers.UserStatus.Busy
                    }
                    if  event == CRMCallHelpers.Event.Cancel.rawValue {
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.CancelEvent, object: nil, userInfo: result)
                        
                        CRMCallManager.shareInstance.myCurrentStatus = CRMCallHelpers.UserStatus.None
                    }
                    if  event == CRMCallHelpers.Event.Busy.rawValue {
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.BusyEvent, object: nil, userInfo: result)
                    }
                    if  event == CRMCallHelpers.Event.Bye.rawValue {
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.ByeEvent, object: nil, userInfo: result)
                        
                        CRMCallManager.shareInstance.myCurrentStatus = CRMCallHelpers.UserStatus.None
                    }
                }
            }
            
        })
    }
    
}
