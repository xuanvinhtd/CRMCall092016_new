//
//  SocketManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class SocketManager: NSObject {
    
    // MARK: - Properties
    private var flagEncrypt: String = "1"
    private var readTimeOut: Double = 60.0
    private var writeTimeOut: Double = 5.0
    
    private var aesExtension: AESExtension?
    private var asynSocket: GCDAsyncSocket?
    
    private var port: UInt16?
    private var host: String?
    
    // MARK: - Initialize
     init (with host: String, port: UInt16) {
        
        super.init()
        
        self.host = host
        self.port = port
        self.aesExtension = AESExtension()
        self.asynSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    // MARK: - Socket handling
    func connect() {
        
        guard let host = self.host, port = self.port else { fatalError() }
        
        do {

           try asynSocket?.connectToHost(host, onPort: port)
            
        } catch let err {
            println("Error connect socket: \(err)")
        }
    }
    
    func disConnect() {
        
        guard let socket = self.asynSocket else { fatalError() }
        
        socket.disconnect()
    }
    
    func configData(With strData: String) {
        
        let encryptData = aesExtension?.aesEncryptString(strData)
        
        let headerData = String(format: "%05lu", (encryptData?.characters.count)! + 1)
        
        let requestData = headerData + String(format: "%@%@", flagEncrypt, encryptData!)
        
        sendData(requestData.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func sendData(data: NSData) {
        asynSocket?.writeData(data, withTimeout: writeTimeOut, tag: CRMCallConfig.Tab.Default)
    }
    
}

// MARK: - Delegate Socket
extension SocketManager: GCDAsyncSocketDelegate {
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        
        if tag == CRMCallConfig.Tab.Header {
            print("data server: \(data)")
        } else if (tag == CRMCallConfig.Tab.BodyData) {
            
        } else {
            
        }
        
    }
    
    func socket(sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        print("lenght: \(partialLength)")
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        println("DidConnet to host: \(host) and post: \(port)")
        
    }
}
