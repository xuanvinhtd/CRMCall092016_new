//
//  CRMCallConfig.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation

final class CRMCallConfig {
    
    static let Version = "20150202"
    static let DeviceID = "MAC"
    static let IsPType = "4"
    
    static let LangID = "en"
    
    static let AppGroupID = "com.xuanvintd.CRMCall092016"
    
    //static let HostName = "global3.hanbiro.com"
    
    static let TimerInterval = 10.0
    
    static let HeaderLength:UInt = 6
    
    static let UUIDKey = "UUID"
    
    // MARK: - UserDefault key
    struct UserDefaultKey {
        static let SIPLoginResult = "SIPLoginResult"
        
        static let AutoLogin = "CRMCallAutoLogin"
        static let SaveID = "CRMCallSaveID"
        
        static let PathLocalSound = "PathLocalSound"
    }
    
    struct KeyChainKey {
        
        static let ServiceName = "com.hanbiro.CRMCall2016"
        static let HostSetting = "HostSetting"
        static let IDSetting = "IDSetting"
        static let PasswordSetting = "PasswordSetting"
        static let PhoneNumberSetting = "PhoneNumberSetting"
        
        static let Domain = "Domain"
        static let UserID = "UserID"
        static let PasswordUser = "PasswordUser"
    }
    
    // MARK: Tab
    struct Tab {
        static let Default = 0
        static let Header = 1
        static let BodyData = 2
    }
    
    // MARK: Notification
    struct Notification {
        static let SocketDidConnected = "CRMCallConfig.Notification.SocketDidConnected"
        static let SocketDisConnected = "CRMCallConfig.Notification.SocketDisConnected"
        static let RecivedServerInfor = "CRMCallConfig.Notification.RecivedServerInfor"
        static let LoginSuccessSocket = "CRMCallConfig.Notification.LoginSuccessSocket"
        static let LoginFailSocket    = "CRMCallConfig.Notification.LoginFailSocket"
        
        static let LiveServer = "CRMCallConfig.Notification.LiveServer"
        
        static let ReConnectSocket = "CRMCallConfig.Notification.ReConnectSocket"
        
        static let RingIng = "CRMCallConfig.Notification.RingIng"
        static let InviteEvent = "CRMCallConfig.Notification.InviteEvent"
        static let InviteResultEvent = "CRMCallConfig.Notification.InviteResultEvent"
        static let CancelEvent = "CRMCallConfig.Notification.CancelEvent"
        static let BusyEvent = "CRMCallConfig.Notification.BusyEvent"
        static let ByeEvent = "CRMCallConfig.Notification.ByeEvent"
        
        static let NotConnetInternet = "CRMCallConfig.Notification.NotConnetInternet"
    }
    
    // MARK: API
    struct API {
        
        static func login(with domain: String) -> String {
            return "https://\(domain)/ngw/sign/sso"
        }
        
        static func phoneType() -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/get_cti_contact_label"
        }
        
        static func purposeList(withCNKey cnKey: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customization/options/options_by_category_langcode/\(cnKey)/activity_purposes/\(CRMCallConfig.LangID)"
        }
        
        static func productList(withCNKey cnKey: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/product/management/list_prod/\(cnKey)"
        }
        
        static func uploadCallHistory(withCompany cn: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/activity/call/\(cn)"
        }
        
        static func getUploadCallHistory(withCompany cn: String, id: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/activity/call/\(cn)/\(id)"
        }
        
        static func searchCustomer(withCompany cn: String, types: [String], pages: [String], keyword: String, sort: String, order: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/search_by/\(cn)/all/all?type=\(types.joinWithSeparator(","))&keyword=\(keyword)&paging=\(pages.joinWithSeparator(","))&sort=\(sort)&order=\(order)"
        }
        
        static func registerEmployee(withCompany cn: String, companyCode: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/employee/add/\(cn)/\(companyCode)/400"
        }
        
        static func registerWithLabel(withCompany cn: String, companyCode: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/customer_field/\(cn)/\(companyCode)/phone"
        }

        
        static func registerTelephoneOfCompany(withCompany cn: String, companyCode: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/customer_field/\(cn)/\(companyCode)/phone"
        }
        
        static func registerTelephoneForEmployee(withCompany cn: String, employeeCode: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/customer_field/\(cn)/\(employeeCode)/phone"
        }
        
        static func registerTelephoneForContact(withCompany cn: String, contactCode: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/customer/management/customer_field/\(cn)/\(contactCode)/phone"
        }
        
        static func searchHistoryCall(withCompany cn: String, limit: Int, offset: Int, sort: String, order: String, since: String, until: String, dateRange: String, type: String) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/activity/search/1?limit=\(limit)&offset=\(offset)&sort=\(sort)&order=\(order)&since=\(since)&until=\(until)&date_range=\(dateRange)&type=\(type)"
        }
        
        static func searchHistoryCallOfCustomer(withCompany cn: String, customerCode: String, limit: Int, offset: Int, sort: String, order: String, type: [String]) -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/activity/search/\(cn)?limit=\(limit)&offset=\(offset)&sort=\(sort)&order=\(order)&since=&until=&type=\(type.joinWithSeparator(","))&customer_code=\(customerCode)"
        }
        
        static func getAllStaffs() -> String {
            return "https://\(CRMCallManager.shareInstance.domain)/ngw/_cti/account/crm_user/user_tree"
        }
        
        static func GetPortAndHostURL(withHostName name: String) -> String {
            return "http://\(name)/winapp/hcsong/crmcall/\(name)/server.xml"
        }
    }
    
}
