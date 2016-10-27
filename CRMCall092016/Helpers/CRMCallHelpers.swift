//
//  CRMCallHelpers.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/14/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift
import KeychainAccess

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
        case ALL = "All"
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
        static let StaffAvailabilityWindowController = "StaffAvailabilityWindowController"
        static let HistoryCallWindowController = "HistoryCallWindowController"
        static let RingIngWindowController = "RingIngWindowController"
        static let CustomerListViewController = "CustomerListViewController"
        static let SettingViewController = "SettingViewController"
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
    
    static func reGetIdAndHost() {
        //GET SETTING INFO
        let keyChain = Keychain(service: CRMCallConfig.KeyChainKey.ServiceName)
        
        let phoneSetting = keyChain[CRMCallConfig.KeyChainKey.PhoneNumberSetting]
        let hostSetting = keyChain[CRMCallConfig.KeyChainKey.HostSetting]
        let idSetting = keyChain[CRMCallConfig.KeyChainKey.IDSetting]
        let pwdSetting = keyChain[CRMCallConfig.KeyChainKey.PasswordSetting]
        
        guard let _ = phoneSetting, host = hostSetting, _ = idSetting, _ = pwdSetting else {
            println("Not found info setting")
            return
        }
        
        if CRMCallManager.shareInstance.isSocketLoginSuccess == false {
            if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {  // SIPLOGIN
                
                crmCallSocket.getIdAndHost(withHostName: host, Result: { (result) in
                    
                })
            } else {
                CRMCallManager.shareInstance.initSocket()
                if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
                    crmCallSocket.getIdAndHost(withHostName: host, Result: { (result) in
                        
                    })
                }
            }
        }
    }
    
    static func reLoginSocket() {
        // GET SETTING INFO
        let keyChain = Keychain(service: CRMCallConfig.KeyChainKey.ServiceName)
        
        let phoneSetting = keyChain[CRMCallConfig.KeyChainKey.PhoneNumberSetting]
        let hostSetting = keyChain[CRMCallConfig.KeyChainKey.HostSetting]
        let idSetting = keyChain[CRMCallConfig.KeyChainKey.IDSetting]
        let pwdSetting = keyChain[CRMCallConfig.KeyChainKey.PasswordSetting]
        
        guard let phone = phoneSetting, host = hostSetting, id = idSetting, pwd = pwdSetting else {
            println("Please, call setting and again. \nGo to Preferences...")
            return
        }
        
        if let crmCallSocket = CRMCallManager.shareInstance.crmCallSocket {
            crmCallSocket.loginRequest(withUserID: id, passwold: pwd, phone: phone, domain: host)
        } else {
            println("CRMCallManager.shareInstance.crmCallSocket = nil")
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
    
    static func createDictionaryStaff(withData data: List<Staff>, phoneNumber: String) -> [[String : AnyObject]]{
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
        
        
        var index = 0
        
        for _ in label {
            let employeeDict = ["label":label[index],"phone_number":phoneNumber[index]]
            index += 1
            result.append(employeeDict)
        }
        
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
        
        data["data"] = result
        
        return data
    }
    
    static func buildTreeStaff(withData data: Results<RootTree>) -> [String: AnyObject] {
        
        var tree: [String: AnyObject] = [:]
        for root in data {
            
            let root0 = Root(icon: NSImage(named: "Image")!, rootTree: root)
            tree[root.title] = root0
            
            for _rootChild in root.rootchildren {
                
                let rootI = RootI(icon: NSImage(named: "Image")!, rootTree: _rootChild)
                
                for child in _rootChild.childrens {
                    
                    let _ = Child(icon: NSImage(named: "Image")!, childTree: child, rootI: rootI)
                }
                root0.rootI.append(rootI)
            }
        }
        
        return tree
    }
    
    static func SearchTreeStaff(withkeySearch keySearch: String, result: ([String: AnyObject]->Void)) {
        
        var tree: [String: AnyObject] = [:]
        Cache.shareInstance.getStaffTree({ (data) in
            guard let trees = data else {
                println("Not found tree data with predicate")
                return
            }
            
            let rootTree = CRMCallHelpers.buildTreeStaff(withData: trees)
            
            for (_ , value) in rootTree {
                
                if let r = value as? Root {
                    let root0 = Root(icon: NSImage(named: "Image")!, rootTree: r.rootTree)
                    tree[r.name] = root0
                    
                    for r1 in r.rootI {
                        let rootI = RootI(icon: NSImage(named: "Image")!, rootTree: r1.rootTree)
                        root0.rootI.append(rootI)
                        
                        if r1.name.containsString(keySearch) {
                            for child in r1.child {
                                    let _ = Child(icon: NSImage(named: "Image")!, childTree: child.childTree, rootI: rootI)
                            }
                        } else {
                            for child in r1.child {
                                if child.name.containsString(keySearch) {
                                    let _ = Child(icon: NSImage(named: "Image")!, childTree: child.childTree, rootI: rootI)
                                }
                            }
                        }
                        
                        
                    }
                }
            }
            
            // Remove Empty node and search root node
            var index = 0
            for (key , value) in tree {
                if let r = value as? Root {
                    if r.rootI.count == 0 && !r.name.containsString(keySearch) {
                        tree.removeValueForKey(key)
                    } else {
                        for r1 in r.rootI {
                            if r1.child.count == 0 && !r1.name.containsString(keySearch) {
                                r.rootI.removeAtIndex(index)
                            } else {
                                index += 1
                            }
                        }
                        
                        if r.rootI.count == 0 {
                            tree.removeValueForKey(key)
                        }
                        index = 0
                    }
                }
            }
            result(tree)
        })
    }
    
}