//
//  StaffAvailabilityViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/14/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

class StaffAvailabilityViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    @IBOutlet weak var sourceView: NSOutlineView!
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return  CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("StaffAvailabilityViewControllerID") as! StaffAvailabilityViewController
    }
    
    func initData() {
        ///-------------- GET ALL STAFF -------------//
        let url = CRMCallConfig.API.getAllStaffs()
        
        AlamofireManager.requestUrlByGET(withURL: url, parameter: nil) { (datas, success) in
            if success {
                println("-----------> Get All Staff data responce: \(datas)")
                
                //                guard let data = datas["rows"] as? [String: AnyObject] else {
                //                    println("Cannot get data after register employee success")
                //                    return
                //                }
            } else {
                println("---XXXXX---->>> Get all staff data fail with message: \(datas)")
            }
        }

    }
    
    // MARK: - View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        // Do view setup here.
    }
    
}
// MARK: - Outline View Data Source
extension StaffAvailabilityViewController: NSOutlineViewDataSource {
    
}

// MARK: - Outline View Data Delegate
extension StaffAvailabilityViewController: NSOutlineViewDelegate {
    
}
