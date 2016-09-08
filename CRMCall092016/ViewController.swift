//
//  ViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/7/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var aesExtension: AESExtension?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aesExtension = AESExtension()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

