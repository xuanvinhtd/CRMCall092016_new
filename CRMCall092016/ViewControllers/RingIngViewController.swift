//
//  RingIngViewController.swift
//  CRMCall092016
//
//  Created by Hanbiro on 9/23/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa
import AVFoundation

class RingIngViewController: NSViewController, ViewControllerProtocol {
    
    // MARK: - Properties
    private var handlerNotificationReceivedDataCaller: AnyObject!
    
    @IBOutlet weak var nameCaller: NSTextField!
    @IBOutlet weak var phoneCaller: NSTextField!
    
    @IBOutlet weak var productsTextField: NSTextField!
    @IBOutlet weak var assignedTextField: NSTextField!
    
    var audioPlayer:AVAudioPlayer?
    
    // MARK: - Initialzation
    static func createInstance() -> NSViewController {
        return CRMCallHelpers.storyBoard.instantiateControllerWithIdentifier("RingIngViewControllerID") as! RingIngViewController
    }
    
    func initData() {
        
        let idCall = CRMCallManager.shareInstance.idCallCurrent
        
        Cache.shareInstance.getRingInfo(with: NSPredicate(format: "callID = %@", idCall)) { (info) in
            
            guard let _info = info?.first else {
                println("======> RingIng Dialog Info NULL <======")
                self.phoneCaller.stringValue = "0"
                return
            }
            
            println("===============> RingIng Dialog Info <===============\n \(_info)")
            
            self.phoneCaller.stringValue = _info.from
            
            Cache.shareInstance.getCustomerInfo(with:  NSPredicate(format: "idx = %@", idCall), Result: { userInfo in
                
                guard let userInfo = userInfo?.first else {
                    println("Not found Info CallID of \(_info.from) and CallID: \(idCall)")
                    self.nameCaller.stringValue = ""
                    return
                }
                
                if userInfo.phone == "0" { // User not register
                    self.phoneCaller.stringValue = _info.from
                } else { // User regestered
                    self.nameCaller.stringValue = userInfo.name
                    self.phoneCaller.stringValue = userInfo.phone
                    
                    var productNames = [String]()
                    for product in userInfo.products {
                        productNames.append(product.name)
                    }
                    self.productsTextField.stringValue = productNames.joinWithSeparator(",")
                    
                    
                    var staffNameList = [String]()
                    for staff in userInfo.staffs {
                        staffNameList.append(staff.name)
                    }
                    self.assignedTextField.stringValue = staffNameList.joinWithSeparator(",")
                }
            })
            
        }
    }
    
    func configItems() {
        // Play Sound
        //        if let path = NSUserDefaults.standardUserDefaults().objectForKey(CRMCallConfig.UserDefaultKey.PathLocalSound) as? String {
        //
        //            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        //            let documentsDirectory: AnyObject = paths[0]
        //            let dataPath = documentsDirectory.stringByAppendingPathComponent(path)
        //
        //            let filePathUrl = NSURL.fileURLWithPath(dataPath)
        //
        //            self.playSound(withUrl: filePathUrl)
        //        } else {
        
        if let audioFilePath = NSBundle.mainBundle().pathForResource("RingSound", ofType: "wav") {
            let audioUrl = NSURL.fileURLWithPath(audioFilePath)
            self.playSound(withUrl: audioUrl)
        } else {
            println("Audio file is not found")
        }
        // }
    }
    
    // MARK: - Initialzation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Init Screen RingIngViewController")
        registerNotification()
        
        configItems()
        
        initData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Call"
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        if let audio = self.audioPlayer {
            audio.stop()
        }
        
        deregisterNotification()
    }
    
    // MARK: - Notification
    struct Notification {
        static let RingCancel = "RingCancel"
        static let RingBusy = "RingBusy"
        static let ReceivedDataCaller = "ReceivedDataCaller"
    }
    
    func registerNotification() {
        handlerNotificationReceivedDataCaller = NSNotificationCenter.defaultCenter().addObserverForName(RingIngViewController.Notification.ReceivedDataCaller, object: nil, queue: nil, usingBlock: { notification in
            
            println("Class: \(NSStringFromClass(self.dynamicType)) recived: \(notification.name)")
            
            self.initData()
        })
    }
    
    func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(handlerNotificationReceivedDataCaller)
    }
    
    // MARK: - Sound
    
    private func playSound(withUrl url: NSURL) {
        do {
            self.audioPlayer? = try AVAudioPlayer(contentsOfURL: url)
            self.audioPlayer?.numberOfLoops = -1
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        } catch let error as NSError {
            println("Cannot play sound error: \(error)")
        }
    }
}