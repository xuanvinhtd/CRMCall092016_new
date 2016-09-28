//
//  LoginViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/23/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Foundation
import Cocoa

final class LoginViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    @IBOutlet weak var domainTextField: NSTextField!
    @IBOutlet weak var userIDTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var isSaveIDCheckBox: NSButton!
    @IBOutlet weak var isAutoLoginCheckBox: NSButton!
    
    @IBOutlet weak var btnLogin: NSButton!
    // MARK: - Intialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("") as! LoginViewController
    }
    
    // MARK: - View life cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init screen LoginViewController")
    }
    
    @IBAction func actionLogin(sender: AnyObject) {
        
        let url = CRMCallConfig.API.login(with: domainTextField.stringValue)
        let parameter = RequestBuilder.login(userIDTextField.stringValue, password: passwordTextField.stringValue)
        AlamofireManager.requestUrlByPOST(withURL: url, parameter: parameter) { (data, success) in
            if success {
                println("-----------> RS = \(data)")
            }
        }
    }

}