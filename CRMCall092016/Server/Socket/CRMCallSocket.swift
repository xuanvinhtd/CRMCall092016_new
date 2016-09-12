//
//  CRMCallSocket.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/12/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class CRMCallSocket: BaseSocket {
    
    // MARK: - Properties
    var timerLive: String
    
    // MARK: - Initialzation
    override init() {
        
        timerLive = ""
        super.init()
        
    }
    
    // MARK: - COMUNICATION API
    
    func requestLogin(withUserID userID: String, passwold: String, domain: String) {
        
        let xmlLogin = XMLRequestBuilder.loginRequest(with: userID, pass: passwold, domain: domain)
        
        configData(withData: xmlLogin)
    }
    
    func requestLogout() {
        
        let xmlLogOut = XMLRequestBuilder.logOutRequest()
        
        configData(withData: xmlLogOut)
    }
    
}