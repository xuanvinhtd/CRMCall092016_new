//
//  CRMCallHelpers.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/14/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

final class CRMCallHelpers {
    
    static let storyBoard = NSStoryboard.init(name: "Main", bundle: nil)
    static let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    enum TypeData {
        case UserLogin
        case UserLogout
        case UserInfo
        case ServerInfo
        case UserLive
        case SIP
        case RingIng
        case None
    }
    
    enum UserStatus: String {
        case None = "0"
        case Ringing = "1"
        case Busy = "2"
    }
    
    enum Direction: String {
        case None = "NONE"
        case InBound = "INBOUND"
        case OutBound = "OUTBOUND"
    }
    
    enum Event: String {
        case Invite = "INVITE"
        case Cancel = "CANCEL"
        case Busy = "BUSY"
        case InviteResult = "INVITE_RESULT"
        case Bye = "BYE"
    }
    
    enum Order: String {
        case Desc = "desc"
        case Asc = "asc"
    }
    
    enum Sort: String {
        case ID = "id"
        case Name = "name"
        case Regdate = "regdate"
        case DateTime = "date_time"
    }
    
    enum CustomerType: String {
        case Company = "Company"
        case Contact = "Contact"
        case Employee = "Employee"
        case ALL = "ALL"
    }

    
    enum TypeApi: String {
        case Company = "company"
        case Contact = "contact"
        case Employee = "employee"
        case Call = "call"
        case Meeting = "metting"
        case Fax = "fax"
        case Post = "post"
        case Appointment = "appointment"
        case Task = "task"
        case Email = "email"
        case Sms = "sms"
    }
    
    struct NameScreen {
        static let LoginWindowController = "LoginWindowController"
        static let HistoryCallWindowController = "HistoryCallWindowController"
        static let RingIngWindowController = "RingIngWindowController"
        static let CustomerListViewController = "CustomerListViewController"
    }
    
    static func getUUID() -> String {
        if let uuid = NSUserDefaults.standardUserDefaults().stringForKey(CRMCallConfig.UUIDKey) {
            return uuid
        } else {
            let uuidObject = CFUUIDCreate(kCFAllocatorDefault)
            let uuid = CFUUIDCreateString(kCFAllocatorDefault, uuidObject)
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: CRMCallConfig.UUIDKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            return uuid as String
        }
    }
    
    static func reconnectToSocket() {
        //GET SETTING INFO
        let phoneSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PhoneNumberSetting) as? String
        let hostSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.HostSetting) as? String
        let idSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.IDSetting) as? String
        let pwdSetting = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PasswordSetting) as? String
        
        guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
            println("Not found info setting")
            return
        }
        
        if CRMCallManager.shareInstance.isSocketLoginSuccess == false {
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {  // SIPLOGIN
                
                if crmCallSocket.isConnectedToHost == true {
                    crmCallSocket.loginRequest(withUserID: id, passwold: pwd, phone: phone, domain: host)
                    
                } else {
                    println("Connect to server again.....")
                    crmCallSocket.connect()
                }
            } else {
                CRMCallManager.shareInstance.initSocket()
            }
        }
    }
    
    static func findKeyForValue(value: String, dictionary: [String: String]) ->String?
    {
        for (key, strValue) in dictionary {
            if (value == strValue) {
                return key
            }
        }
        
        return nil
    }
    
    // MARK: - CREATE DICTIONARY STAFF, PURPOSE, CUSTOMER
    
    static func createDictionaryStaff(withData data: [Staff], phoneNumber: String) -> [[String : AnyObject]]{
        var result = [[String : AnyObject]]()
        
        for item in data {
            var staffDict = [String : AnyObject]()
            staffDict["staff_cn"] = item.cn
            staffDict["staff_no"] = item.no
            staffDict["staff_name"] = item.name
            staffDict["staff_phone"] = phoneNumber
            
            result.append(staffDict)
        }
        
        return result
    }
    
    static func createDictionaryCustomer(withData data: UserInfo) -> [[String : AnyObject]]{
        var result = [[String : AnyObject]]()
        
        var staffDict = [String : AnyObject]()
        staffDict["customer_cn"] = data.cn
        staffDict["customer_code"] = data.code
        staffDict["customer_name"] = data.name
        staffDict["customer_phone"] = data.phone
        staffDict["parent_name"] = data.parentName
        
        result.append(staffDict)
        
        return result
    }
    
    static func createDictionaryPurpose(withData data: [NSMutableDictionary]) -> [[String : AnyObject]]{
        var result = [[String : AnyObject]]()
        
        for item in data {
            var purposeDict = [String : AnyObject]()
            
            let isCheck = item["CheckID"] as! Int
            if isCheck == 1 {
                let valueStr = item["id"] as! String
                purposeDict["id"] = valueStr
                result.append(purposeDict)
            }
        }
        
        return result
    }
    
    static func createDictionaryEmployee(withData label: [String], phoneNumber: [String]) -> [[String : AnyObject]]{
        var result = [[String : AnyObject]]()
        
        var employeeDict = [String : AnyObject]()
        var index = 0
        
        for _ in label {
            employeeDict["label"] = label[index]
            employeeDict["phone_number"] = phoneNumber[index]
            index += 0
        }
        
        result.append(employeeDict)
        
        return result
    }
    
    static func createDictionaryTelephoneOfSomeOne(withData label: String, phoneNumber: String, cateID: String, cn: String) -> [String : AnyObject]{
        
        var data = [String : AnyObject]()
        var result = [String : AnyObject]()
        
        result["label"] = label
        result["phone_number"] = phoneNumber
        result["cate_id"] = cateID
        result["cn"] = cn
        
        data["data"] = result
        
        return data
    }
    
    static func createDictionaryRegisterManually(withData label: String, labelValue: String, phoneNumber: String, cateID: String, cn: String) -> [String : AnyObject]{
        
        var data = [String : AnyObject]()
        var result = [String : AnyObject]()
        
        result["label"] = label
        result["label_value"] = labelValue
        result["phone_number"] = phoneNumber
        result["cate_id"] = cateID
        result["cn"] = cn
        
        data["data"] = result
        
        return data
    }

}