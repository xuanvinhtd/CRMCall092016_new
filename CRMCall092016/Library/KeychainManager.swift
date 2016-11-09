//
//  KeychainManager.swift
//  CRMCall092016
//
//  Created by Hanbiro on 11/8/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa
import KeychainAccess

class KeyChainManager {
    static let shareInstance = KeyChainManager()
    private let keyChain: Keychain!
    
    struct Keys {
        static let ServiceName = "com.hanbiro.CRMCall2016"
        static let HostSetting = "HostSetting"
        static let IDSetting = "IDSetting"
        static let PasswordSetting = "PasswordSetting"
        static let PhoneNumberSetting = "PhoneNumberSetting"
        
        static let Domain = "Domain"
        static let UserID = "UserID"
        static let PasswordUser = "PasswordUser"
    }
    
    private init() {
        keyChain = Keychain(service: Keys.ServiceName)
    }
    
    func getValue(withKey key: String) -> String? {
        return keyChain[key]
    }
    
    func saveSettingInfo(withPhone phone: String, host: String, id: String, password: String) {
        keyChain[Keys.PhoneNumberSetting] = phone
        keyChain[Keys.HostSetting] = host
        keyChain[Keys.IDSetting] =  id
        keyChain[Keys.PasswordSetting] = password
    }
    
    func getSettingInfo() -> [String: String] {
        let phoneSetting = keyChain[Keys.PhoneNumberSetting] ?? ""
        let hostSetting = keyChain[Keys.HostSetting] ?? ""
        let idSetting = keyChain[Keys.IDSetting] ?? ""
        let pwdSetting = keyChain[Keys.PasswordSetting] ?? ""
        
        return [Keys.PhoneNumberSetting: phoneSetting,
                Keys.HostSetting: hostSetting,
                Keys.IDSetting: idSetting,
                Keys.PasswordSetting: pwdSetting]
    }
    
    func saveUserInfo(withDomain domain: String, userID: String, password: String) {
        keyChain[Keys.Domain] = domain
        keyChain[Keys.UserID] = userID
        keyChain[Keys.PasswordUser] =  password
    }
    
}
