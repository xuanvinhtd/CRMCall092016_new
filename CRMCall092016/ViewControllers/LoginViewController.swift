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
    
    // MARK: - Intialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("") as! LoginViewController
    }
    
    // MARK: - View life cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init screen LoginViewController")
    }
    
}