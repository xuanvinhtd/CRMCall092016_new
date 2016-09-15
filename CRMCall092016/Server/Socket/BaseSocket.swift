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

    private var port: UInt16
    private var host: String
    
    // MARK: - Initialize
    
    override init() {
        
        self.host = ""
        self.port = 0
        self.aesExtension = AESExtension()
        
        self.socketQueue = dispatch_queue_create("Socket.queue", DISPATCH_QUEUE_SERIAL)
        
        super.init()
        
        self.asynSocket = GCDAsyncSocket(delegate: self, delegateQueue: self.socketQueue)
        
        getIdAndHost()
    }
    
    deinit {
        self.asynSocket = nil
    }
    
    // MARK: - Socket handling
    
    func connect() {
        
        dispatch_async(socketQueue) {
            do {
                if self.host != "" && self.port != 0 {
                    try self.asynSocket.connectToHost(self.host, onPort: self.port)
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
    
    private func getIdAndHost() {
        
        AlamofireManager.getData(withURL: CRMCallConfig.API.GetPortAndHostURL) { response in
            
            guard let _response = response else {
                println("Cannot get port and host to hostName: \(CRMCallConfig.HostName)")
                return
            }
            
            guard let xml = NSString(data: _response, encoding: NSUTF8StringEncoding) as? String else {
                println("Not found data to server")
                return
            }
            
            SWXMLHashManager.parseXMLToDictionary(withXML: xml, Completion: { result, typeData in
                
                if typeData == CRMCallHelpers.TypeData.ServerInfo {
                    
                    println("---------> Data server infor: \n\(result)")
                    
                    if let port = result["PORT"], host = result["IP"] {
                        self.port = UInt16(port)!
                        self.host = host
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.RecivedServerInfor, object: nil, userInfo: nil)
                    } else {
                        println("Cannot parse port and host: \(CRMCallConfig.HostName)")
                    }
                }
            })
        }
    }
}

// MARK: - Socket Delegate 
extension BaseSocket: GCDAsyncSocketDelegate {
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        
      //  dispatch_async(socketQueue) {
            if tag == CRMCallConfig.Tab.Header {
                
                guard let headerData = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                    fatalError("Not found header data")
                }
                
                println("Recived data header: \(headerData)")
                
                let lenghtHeader = (UInt(headerData.substringToIndex(5))! - 1)
                self.flagEncrypt = headerData.substringFromIndex(5)
                
                self.asynSocket.readDataToLength(lenghtHeader, withTimeout: self.readTimeOut , tag: CRMCallConfig.Tab.BodyData)
                
                
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
                
                SWXMLHashManager.parseXMLToDictionary(withXML: decryptBodyData, Completion: { result, typeData in
                    
                    if typeData == CRMCallHelpers.TypeData.UserLogout {
                        
                        println("---------> Data logout user : \n\(result)")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.LogoutSuccess, object: nil, userInfo: nil)
                    }
                    
                    if typeData == CRMCallHelpers.TypeData.UserLogin {
                        
                        println("---------> Data login user : \n\(result)")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.LoginSuccess, object: nil, userInfo: nil)
                    }
                    
                    if typeData == CRMCallHelpers.TypeData.UserLive {
                        
                        println("---------> Data live : \n\(result)")
                    }

                })
            }
     //   }
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        println("Did connet to host: \(host) and post: \(port)")
        
        isConnectedToHost = true
        
        asynSocket.readDataToLength(CRMCallConfig.HeaderLength, withTimeout: readTimeOut, tag: CRMCallConfig.Tab.Header)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.SocketDidConnected, object: nil, userInfo: nil)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        
        println("Error DidDisconnect: \(err)")
        
        self.isConnectedToHost = false
        
        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.SocketDisConnected, object: nil, userInfo: nil)
    }
}
