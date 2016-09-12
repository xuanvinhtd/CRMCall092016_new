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

    private var port: UInt16
    private var host: String
    
    // MARK: - Initialize
    
    init(withHost host: String, port: UInt16) {

        self.host = host
        self.port = port
        self.aesExtension = AESExtension()
        
        super.init()
        
        self.asynSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    override init() {
        
        self.host = ""
        self.port = 0
        self.aesExtension = AESExtension()
        
        super.init()
        
        self.asynSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        getIdAndHost()
    }
    
    // MARK: - Socket handling
    
    func connect() {
        
        do {

           try asynSocket.connectToHost(host, onPort: port)
            
        } catch let err {
            println("Error connect socket: \(err)")
        }
    }
    
    func disConnect() {
        
        asynSocket.disconnect()
        
        isConnectedToHost = false
    }
    
    func configData(withData strData: String) {
        
        let encryptData = aesExtension.aesEncryptString(strData)
        
        let headerData = String(format: "%05lu", (encryptData?.characters.count)! + 1)
        
        let requestData = headerData + String(format: "%@%@", flagEncrypt, encryptData!)
        
        sendData(requestData.dataUsingEncoding(NSUTF8StringEncoding)!)
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
            
            guard let result = NSString(data: _response, encoding: NSUTF8StringEncoding) as? String else {
                println("Not found data to server")
                return
            }
            
            let resultDic = SWXMLHashManager.parseXMLToDictionary(withXML: result)
            
            if let port = resultDic["PORT"], host = resultDic["IP"] {
                self.port = UInt16(port)!
                self.host = host
            } else {
                println("Cannot parse port and host: \(CRMCallConfig.HostName)")
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(ViewController.Notification.connectToHost, object: nil, userInfo: nil)
        }
    }
}

// MARK: - Socket Delegate 
extension BaseSocket: GCDAsyncSocketDelegate {
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        
        if tag == CRMCallConfig.Tab.Header {
            
            guard let headerData = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                fatalError("Not found header data")
            }

            println("Data header: \(headerData)")
            
            let lenghtHeader = (UInt(headerData.substringToIndex(5))! - 1)
            flagEncrypt = headerData.substringFromIndex(5)
            
            asynSocket.readDataToLength(lenghtHeader, withTimeout: readTimeOut , tag: CRMCallConfig.Tab.BodyData)
            
            
        } else if (tag == CRMCallConfig.Tab.BodyData) {
            
            guard let bodyData = NSString(data: data, encoding: NSUTF8StringEncoding) as? String else {
                fatalError("Not found body data")
            }

            var decryptBodyData = ""
            
            if flagEncrypt == "1" {
                
                guard let dataDecrypt = aesExtension.aesDecryptString(bodyData) else {
                    fatalError("Not Decrypt body data")
                }
                
                decryptBodyData = dataDecrypt
            } else {
                decryptBodyData = bodyData
            }
            
            println("Data body: \(decryptBodyData)")
            
            asynSocket.readDataToLength(CRMCallConfig.HeaderLength, withTimeout: readTimeOut, tag: CRMCallConfig.Tab.Header)
            
            SWXMLHashManager.parseXMLToDictionary(withXML: decryptBodyData)
        }
    }
    
    func socket(sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        println("lenght: \(partialLength)")
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        println("Did connet to host: \(host) and post: \(port)")
        
        isConnectedToHost = true
        
        asynSocket.readDataToLength(CRMCallConfig.HeaderLength, withTimeout: readTimeOut, tag: CRMCallConfig.Tab.Header)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CRMCallConfig.Notification.SocketDidConnected, object: nil, userInfo: nil)
    }
}
